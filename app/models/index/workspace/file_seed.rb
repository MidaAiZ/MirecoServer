class Index::Workspace::FileSeed < ApplicationRecord
  # ----------------------根目录文件----------------------- #
  belongs_to :root_file, -> { with_del },
             polymorphic: true,
             optional: true

  # ----------------------所有未删文件---------------------- #
  has_many :articles,
           class_name: 'Index::Workspace::Article',
           foreign_key: 'file_seed_id'

  has_many :folders,
           class_name: 'Index::Workspace::Folder',
           foreign_key: 'file_seed_id'

  has_many :corpuses,
           class_name: 'Index::Workspace::Corpus',
           foreign_key: 'file_seed_id'

  # -----------------------标星文件----------------------- #
  has_many :mark_records,
            class_name: 'Index::Workspace::MarkRecord',
            foreign_key: :file_seed_id

  # ----------------包括所有子目录下的所有文件,包含已删除的---------------- #
  has_many :articles_with_del, -> { with_del },
           class_name: 'Index::Workspace::Article',
           foreign_key: 'file_seed_id',
           dependent: :delete_all

  has_many :folders_with_del, -> { with_del },
           class_name: 'Index::Workspace::Folder',
           foreign_key: 'file_seed_id',
           dependent: :delete_all

  has_many :corpuses_with_del, -> { with_del },
           class_name: 'Index::Workspace::Corpus',
           foreign_key: 'file_seed_id',
           dependent: :delete_all

  # ---------------------作者角色和作者---------------------- #
  has_many :editor_roles, -> { all_with_del },
           class_name: 'Index::Role::Edit',
           foreign_key: 'file_seed_id',
           dependent: :destroy

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor_role, -> { where(name: :own).all_with_del },
          class_name: 'Index::Role::Edit',
          foreign_key: 'file_seed_id'

  has_one :own_editor,
          through: :own_editor_role,
          source: :editor

  #--------------------------回收站--------------------------- #
  has_many :trashes,
           class_name: 'Index::Workspace::Trash',
           foreign_key: 'file_seed_id',
           dependent: :destroy

  #--------------------------作用域--------------------------- #
  scope :deleted, -> { rewhere(is_deleted: true) }
  # 默认域
  default_scope { order('index_file_seeds.id DESC') }

  # ---------------------判断是否是协作文件---------------------- #
  def is_cooperate?
    editors_count > 1
  end

  # -----------------------创建并设置目录----------------------- #
  def self.create(_self, dir, user, attrs)
    return false if _self.id
    ApplicationRecord.transaction do
      if dir == 0 # 在根目录内创建文件
        file_seed = _self.create_file_seed!(editors_count: 0)
        _self.file_seed = file_seed
        _self.save!
        file_seed.root_file = _self # 将fileseed根文件指针指向新建文件
        file_seed.save!
        user.add_edit_role :own, file_seed # 设置文件所有权
      else # 在父目录内创建文件
        return false if _self.allow_dir_types.exclude? dir.file_type # 检查文件类型合法性
        _self.dir = dir
        _self.file_seed = _self.dir.file_seed
        _self.save!
        set_file_info _self, dir # 设置文件目录信息
      end
      _self.create_content! attrs if _self.file_type == :articles # 当文件类型为文章时创建文章内容

      return true
    end
    # rescue
    #   return false
  end

  # ----------------------查询所有文件---------------------- #
  def files
    f_hash = {}
    articles = articles_with_del || Index::Workspace::Article.none
    corpuses = corpuses_with_del || Index::Workspace::Corpus.none
    folders = folders_with_del || Index::Fodler.none
    f_hash[:files_count] = articles.to_ary.size + corpuses.to_ary.size + folders.to_ary.size
    f_hash[:articles] = articles
    f_hash[:corpuses] = corpuses
    f_hash[:folders] = folders
    f_hash
  end

  # ------------------------移动文件------------------------ #
  def self.move_dir(_self, target_dir, user) # target_dir = 0 时表示将文件移到根目录
    t1 = Time.now
    file_type = target_dir == 0 ? 0 : target_dir.file_type
    return false if _self.allow_dir_types.exclude? file_type # 检查目标目录是否合法
    # begin

    file_seed = _self.file_seed # 获取当前文件的file_seed
    if target_dir != 0 # 非移入根目录
      return false if target_dir == _self # 防止自循环嵌套
      target_seed = target_dir.file_seed

      # 不允许将外部协作文件移入新的协作文件, 会造成意外的嵌套　条件：1．属于不同协作域  2．原文件协作　3．目标文件协作　
      return false if file_seed != target_seed && # 判断是否是外部文件
                      file_seed.is_cooperate? && # 判断是否是协作文件
                      target_seed.is_cooperate? # 　判断是否是文件夹

    end

    ApplicationRecord.transaction do # 出错将回滚
      return change_edit_dir _self, target_dir, user if _self.is_root? # 移动一整个协同的文件,仅更改文件在其个人文件系统中的目录
      return false unless user.can_edit?(:move_dir, _self) # 检验用户对被移动文件的权限 TODO：耦合太高，之后考虑将权限验证改到控制器里
      if target_dir == 0 # 将文件移动到根目录
        # 将协同协作的文件夹(文集)内的文件移动到根目录,仅拥有者具有该权限
        return move_to_root(_self, user)
      else # 将文件移入另一个文件夹内
        if file_seed == target_seed # 如果目标文件和该文件属于同一个file_seed, 只需保存新路径即可
          return move_to_same_seed _self, target_dir
        else
          return move_to_other_seed _self, target_dir, user
        end
      end
      puts '输出时间消耗------------------------------------------------------------'
      puts Time.now - t1
    end
    # rescue
    #   return false
    # end
  end

  private

  def self.change_edit_dir(_self, target_dir, user)
    file_seed = _self.file_seed
    role = user.all_edit_roles.find_by file_seed_id: file_seed.id # 从缓存中读取
    return false unless role
    origin_dir = role.dir
    if target_dir == 0
      return true if role.is_root # 原本就已经位于根目录
      _self.dir = nil
      set_roles_info origin_dir, role, 'delete'
      role.update is_root: true, dir_id: nil, dir_type: nil
    else
      return true if _self.dir == target_dir # 原本就已经位于该目录
      return false unless user.has_edit_role?(:own, target_dir)
      if !file_seed.is_cooperate? # 非协作文件移动文件时修改seed
        files = _self.files
        return false if files.include? target_dir # 防止文件夹嵌套
        reset_seed _self, target_dir, files
      else
        role.dir = target_dir # 仅修改协作用户个人的显示目录, 所以修改的是role的dir属性
        role.save!
        set_roles_info target_dir, role
        _self.dir = target_dir if role.name == 'own' # 如果操作者是拥有者,直接修改dir,以便相关操作
      end
    end
    target_dir = nil if target_dir == 0
    set_file_info(_self, target_dir, origin_dir)
    _self.save!
  end

  def self.reset_seed(_self, target_dir, files) # 重置fileseed指针
    file_seed = _self.file_seed
    return true if file_seed == target_dir.file_seed # 相同seed无需重设
    _self.dir = target_dir
    target_seed = target_dir.file_seed
    update_target_seed(_self, target_seed, files)
    file_seed.trashes.update_all file_seed_id: target_seed.id
    file_seed.editor_roles.delete_all
    file_seed.delete
  end

  def self.set_roles_info(dir, role, status = 'add') # 设置父目录的子文件信息，弱关联，提供由父文件查找子文件的反向关联信息
    return false unless dir
    if status == 'add' # 父目录添加子文件，操作对象：移动的目标目录
      dir.info['son_roles'] = Set.new(dir.info['son_roles']).add role.id
    elsif status == 'delete' # 父目录移除子文件，操作对象： 移出的原目录
      dir.info['son_roles'] = Set.new(dir.info['son_roles']).delete role.id
      dir.info.delete 'son_roles' if dir.info['son_roles'].blank?
    end
    dir.save!
  end

  def self.move_to_root(_self, user) # 移动目标文件到根目录
    return false unless user.has_edit_role?(:own, _self)
    # 以下将文件移动到根目录, 首先新建一个file_seed, 再移动文件
    target_seed = Index::Workspace::FileSeed.new # 新建fileseed
    target_seed.root_file = _self # 复制根文件
    target_seed.save!
    # 更新拥有者, 原协同协作用户对该被移动文件的权限将失效
    user.add_edit_role :own, target_seed
    origin_dir = _self.dir
    _self.dir = nil
    do_move _self, target_seed, origin_dir
  end

  def self.move_to_same_seed(_self, target_dir) # 移动目标文件到同一个fileseed下的目录内
    return true if _self.dir == target_dir
    if _self.files[target_dir.file_type].exclude?(target_dir) # 防止文件夹嵌套
      origin_dir = _self.dir
      _self.dir = target_dir
      set_file_info(_self, target_dir, origin_dir)
      return _self.save!
    end
  end

  def self.move_to_other_seed(_self, target_dir, user) # 移动文件到另一个fileseed内的目录内
    return false unless user.has_edit_role?(:own, _self) # TODO 降低权限耦合
    return false unless user.has_edit_role?(:own, target_dir)
    files = _self.files
    if files[target_dir.file_type].exclude?(target_dir) # 防止文件夹嵌套
      origin_dir = _self.dir
      _self.dir = target_dir
      return do_move(_self, target_dir.file_seed, origin_dir, files)
    end
    false
  end

  def self.do_move(_self, target_seed, origin_dir, files = nil) # 移动操作
    # 获取_self文件的子文件
    files ||= _self.files
    # 修改目标file_seed信息并将_self的file_seed指向target_seed
    update_target_seed _self, target_seed, files
    # 更新dir和_self的info
    set_file_info _self, _self.dir, origin_dir
  end

  def self.update_target_seed(_self, target_seed, files) # 更新目标目录的fileseed信息
    f_s_id = target_seed.id
    Index::Workspace::Article.where(id: files[:articles].map(&:id)).update_all file_seed_id: f_s_id if files[:articles].any? # 更新file_seed
    Index::Workspace::Corpus.where(id: files[:corpuses].map(&:id)).update_all file_seed_id: f_s_id if files[:corpuses].any? # 更新file_seed
    Index::Workspace::Folder.where(id: files[:folders].map(&:id)).update_all file_seed_id: f_s_id if files[:folders].any? # 更新file_seed

    # 更新文件的file_seed
    _self.file_seed = target_seed
    _self.save!
  end

  def self.set_file_info(_self, target_dir, origin_dir = nil) # 设置文件的信息
    if target_dir
      info = target_dir.info
      key = _self.file_type.to_s
      info[key] = Set.new(info[key]).add _self.id
      target_dir.update! info: info
    end
    if origin_dir
      info = origin_dir.info
      key = _self.file_type.to_s
      info[key] = Set.new(info[key]).delete _self.id
      info.delete key if info[key].blank?
      origin_dir.update! info: info
    end
  end
end

# ---------------遍历所有文件, 按文件目录嵌套--------------- #

# def files_in_order
#   f_hash = {}
#   files.each do |f|
#     f_hash.merge files_in_order(f)
#   end
#   f_hash
# end

# # 迭代遍历
# def self.files_in_order(file, index = 0, f_hash = {})
#   index ||= 0
#   index += 1
#   class_name = file.itself.class.name
#   case class_name
#   when 'Index::Workspace::Folder'
#     if file.son_folders # {folders: [ {folder: @folder, folders: [...], corpuses: [...], articles: [...]} ]}
#       f_arrs = []
#       file.son_folders.each do |f|
#         _f_hash = { folder: f }
#         f_son_hash = files_in_order(f, index)
#         _f_hash.merge f_son_hash
#         f_arrs.push _f_hash
#       end
#       f_hash[:folders] = f_arrs
#     end
#
#     if file.son_corpus # {corpuses: [ {corpus: @corpus, articles: [...]}, {...}, {...} ]}
#       c_arrs = []
#       file.son_corpus.each do |c|
#         c_hash = { corpus: c }
#         c_art_hash = files_in_order(c, index)
#         c_hash.merge c_art_hash
#         c_arrs.push c_hash
#       end
#       f_hash[:corpuses] = c_arrs
#     end
#
#     f_hash[:articles] = file.son_articles if file.son_articles # {articles: [...]}
#   when 'Index::Workspace::Corpus'
#     f_hash[:articles] = file.son_articles
#   when 'Index::Workspace::Article'
#     f_hash[:article] = file
#   end
#   new_f_hash = { index.to_s => f_hash }
#   new_f_hash
# end
