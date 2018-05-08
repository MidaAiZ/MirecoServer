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

  # ----------------包括所有子目录下的所有文件,包含已删除的---------------- #
  has_many :articles_with_del, -> { with_del },
           class_name: 'Index::Workspace::Article',
           foreign_key: 'file_seed_id',
           dependent: :destroy

  has_many :folders_with_del, -> { with_del },
           class_name: 'Index::Workspace::Folder',
           foreign_key: 'file_seed_id',
           dependent: :destroy

  has_many :corpuses_with_del, -> { with_del },
           class_name: 'Index::Workspace::Corpus',
           foreign_key: 'file_seed_id',
           dependent: :destroy

  # ---------------------作者角色和作者---------------------- #
  has_many :editor_roles, -> { all_with_del.reorder(id: :ASC) },
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

  #--------------------------作用域--------------------------- #
  # scope :deleted, -> { rewhere(is_deleted: true) }
  # 默认域
  default_scope { order('index_file_seeds.id DESC') }

  # ---------------------判断是否是协作文件---------------------- #
  def is_cooperate?
    editors_count > 1
  end

  # -----------------------创建并设置目录----------------------- #
  def self.create(_self, dir, user, attrs)
    return false if _self.id
    dir ||= 0
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
        _self.file_seed = dir.file_seed
        _self.save!
        set_file_info _self, dir # 设置文件目录信息
      end
      _self.create_inner_content! attrs if _self.file_type == :articles # 当文件类型为文章时创建文章内容

      return true
    end
    # rescue
    #   return false
  end

  # ----------------------所有子孙后代节点文件---------------------- #
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

  def self.move_dir _self, dir, user
    mover = Index::Workspace::FileMover.new(_self, dir, user)
    return mover.move_dir
  end

  private

  def self.set_file_info(_self, target_dir, origin_dir = nil) # 设置文件的信息
    return true if origin_dir == target_dir

    if target_dir
      target_dir.set_file_node _self
    end
    if origin_dir
      origin_dir.remove_file_node _self
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
