class Index::Workspace::FileMover
  # ----------------------------移动文件--------------------------- #
  # ------------------------逻辑判断天昏地暗------------------------ #

  # 文件移动判定表 前提：对原文件/目标文件具有移出/移入权限
  # 根文件：Root | 子文件：SON | 原创: OWN | 协作：CO | 桌面: TB
  # T表示在具有移动权限的前提下可以实施移动操作，F表示任何情况下不可以执行移动操作

  #                       目       标       路       径
  #     -------------------------------------------------------------
  #        |     条件     |   OWN   |  OWN CO  |   CO    |   TB   |
  # 源  -------------------------------------------------------------
  #        |   OWN ROOT  |    T    |     T    |    T    |    T   |
  #     -------------------------------------------------------------
  #        |   OWN SON   |    T    |     T    |    T    |    T   |
  #     -------------------------------------------------------------
  # 文     | OWN CO ROOT |    T    |     F    |    F    |    T   |
  #     -------------------------------------------------------------
  #        | OWN CO SON  |    T    |    T     |    T    |    T   |
  #     -------------------------------------------------------------
  #        |   CO ROOT   |    T    |    T     |    F    |    T   |
  # 件  -------------------------------------------------------------
  #        |   CO SON    |    F    |    F     |    F    |    F   |
  #     -------------------------------------------------------------

  def initialize file, target_dir, user
    @file = file
    @user = user
    @origin_dir = file.dir
    @target_dir = target_dir
    @file_seed = @file.file_seed
    @role = @user.find_edit_role(@file)

    @files = @file.files # 文件内的所有子文件，用到时才会执行（敲耗资源的骚操作）
  end

  def can_move? fkeys
    _TFTable = {
      OR_O:  true,  OR_OC:  true,   OR_C:  true,
      OS_O:  true,  OS_OC:  true,   OS_C:  true,
      OCR_O: true,  OCR_OC: false,  OCR_C: false,
      OCS_O: true,  OCS_OC: true,   OCS_C: true,
      CR_O:  true,  CR_OC:  false,  CR_C:  false,
      CS_O:  false, CS_OC:  false,  CS_C:  false,
    }

    key = fkeys[0] + "_" + fkeys[1]
    _TFTable[key.to_sym]
  end

  def mv_OR_to_O
    change_edit_dir # 移动一整个协同的文件,仅更改文件在其个人文件系统中的目录
  end

  def mv_OR_to_OC
    change_edit_dir # 移动一整个协同的文件,仅更改文件在其个人文件系统中的目录
  end

  def mv_OR_to_C
    change_edit_dir # 移动一整个协同的文件,仅更改文件在其个人文件系统中的目录
  end

  def mv_OS_to_O
    if @target_dir == 0
      move_son_to_root
    else
      move_son_to_son
    end
  end

  def mv_OS_to_OC
    move_son_to_son
  end

  def mv_OS_to_C
    move_son_to_son
  end

  def mv_OCR_to_O
    change_edit_dir # 移动一整个协同的文件,仅更改文件在其个人文件系统中的目录
  end

  def mv_OCS_to_O
    # 将协同协作的文件夹(文集)内的文件移动到根目录,仅拥有者具有该权限
    if @target_dir == 0
      move_son_to_root
    else
      move_son_to_son
    end
  end

  def mv_OCS_to_OC
    move_son_to_son
  end

  def mv_OCS_to_C
    move_son_to_son
  end

  def mv_CR_to_O
    change_edit_dir # 移动一整个协同的文件,仅更改文件在其个人文件系统中的目录
  end

  def get_file_key
    f_own = @role.is_author? ? "O" : ""
    f_coo = @file.is_cooperate? ? "C" : ""
    f_pos = @file.is_root? ? "R" : "S"

    d_own = @target_dir == 0 || @user.has_edit_role?(:own, @target_dir) ? "O" : ""
    d_coo = @target_dir == 0 || !@target_dir.is_cooperate? ? "" : "C"

    [f_own + f_coo + f_pos, d_own + d_coo]
  end

  def move_dir # @target_dir = 0 时表示将文件移到根目录
    file_type = @target_dir == 0 ? 0 : @target_dir.file_type
    return false if @file.allow_dir_types.exclude? file_type # 检查目标目录是否合法

    fkeys = get_file_key
    return false unless can_move? fkeys

    if @target_dir != 0 # 非移入根目录
      return false if @target_dir == @file # 防止自循环嵌套
      @target_seed = @target_dir.file_seed
    end

    ApplicationRecord.transaction do # 出错将回滚
      if self.send('mv_' + fkeys[0] + '_to_' + fkeys[1])
        after_move
      end
    end
    true
  end

  private

  def after_move
    @target_dir = nil if @target_dir == 0
    if @file.dir != @origin_dir || @role.dir != @origin_id
      @origin_dir && @origin_dir.remove_file_node(@file)
      @target_dir && @target_dir.set_file_node(@file)

      @origin_dir && @origin_dir.remove_role_node(@role)
      @target_dir && @target_dir.set_role_node(@role)
    end
  end

  # 将子文件移入另一个文件内
  def move_son_to_son
    if @file_seed == @target_seed # 如果目标文件和该文件属于同一个file_seed, 只需保存新路径即可
      return move_to_same_seed
    else
      return move_to_other_seed
    end
  end

  # 将文件从桌面移入另一个文件内
  def move_root_to_son
    if @file_seed.is_cooperate?
      @role.dir = @target_dir # 仅修改协作用户个人的显示目录, 所以修改的是role的dir属性
      @role.save!
    else # 非协作文件移动文件时修改seed
      @file.dir = @target_dir # 如果操作者是拥有者,直接修改dir,以便相关操作
      reset_file_seed
    end
  end

  # 移动目标文件到根目录
  def move_son_to_root
    return false unless @role.is_author?
    # 以下将文件移动到根目录, 首先新建一个file_seed, 再移动文件
    @target_seed = @file.build_file_seed # 新建file_seed
    @target_seed.root_file = @file # 复制根文件
    @target_seed.save!
    @user.add_edit_role :own, @target_seed
    @file.dir = nil
    update_file_seed
  end

  # 将role根文件移动到桌面
  def move_root_to_table
    return true if @role.is_root? # 原本就已经位于桌面
    @file.dir = nil
    @role.dir = nil
    @role.save!
  end

  def change_edit_dir
    return false unless @file.is_root?
    @origin_dir = @role.dir # 实际origin_dir为role所指向的根文件，故重设。原先 @origin_dir == @file.dir == nil
    if @target_dir == 0
      move_root_to_table
    else
      return true if @file.dir == @target_dir # 原本就已经位于该目录
      # return false unless @user.has_edit_role?(:own, @target_dir) # 要求目标文件一定属于操作用户
      return false if @files[@target_dir.file_type].include? @target_dir # 防止文件夹嵌套

      @file_seed.reload # BUG 不reload的话editors_counter异常，值恒为1
      move_root_to_son
    end
    @file.save!
  end

  def move_to_same_seed # 移动目标文件到同一个fileseed下的目录内
    return true if @file.dir == @target_dir

    if @files[@target_dir.file_type].exclude?(@target_dir) # 防止文件夹嵌套
      @file.dir = @target_dir
      return @file.save!
    end
  end

  def move_to_other_seed # 移动文件到另一个fileseed内的目录内
    return false unless @role.is_author?
    if @files[@target_dir.file_type].exclude?(@target_dir) # 防止文件夹嵌套
      @file.dir = @target_dir
      return update_file_seed
    end
  end

  def reset_file_seed # 重置fileseed指针
    return true if @file_seed == @target_seed # 相同seed无需重设
    update_file_seed
    @file_seed.root_file = nil
    @file_seed.destroy!
  end

  def update_file_seed # 更新目标目录的fileseed信息
    f_s_id = @target_seed.id
    Index::Workspace::Article.where(id: @files[:articles].map(&:id)).update_all file_seed_id: f_s_id if @files[:articles].any? # 更新file_seed
    Index::Workspace::Corpus.where(id: @files[:corpuses].map(&:id)).update_all file_seed_id: f_s_id if @files[:corpuses].any? # 更新file_seed
    Index::Workspace::Folder.where(id: @files[:folders].map(&:id)).update_all file_seed_id: f_s_id if @files[:folders].any? # 更新file_seed

    # 更新文件的file_seed
    @file.file_seed = @target_seed
    @file.save!
  end

end
