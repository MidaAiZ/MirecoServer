module FileController
    def show
    end

    def update
      prms = file_update_params # 获取更新数据
      if @user.can_edit?(:update, @file)
        @code = if @file.is_deleted || (@file.methods.include?(:is_shown) && @file.is_shown) # 已发表或者删除的文件禁止编辑
                  :StatusError
                else
                  @file.update(prms) ? :Success : :Fail
                end
      else
        @code = :NoPermission
      end

      do_update_response
    end

    # 文件标星和取消标星属于个人目录内的操作，不检查权限
    def mark
      @code = Index::Workspace::MarkRecord._create(@user, @file) ? :Success : :Fail
      do_update_response
    end

    def unmark
      @mark_record = @file.mark_records.find_by_user_id(@user.id)
      @code = @mark_record && @mark_record._destroy(@user, @file) ? :Success : :Fail
      do_update_response
    end

    def rename
      if @user.can_edit?(:update, @file)
        @code = @file.update(name: params[:name]) ? :Success : :Fail
      else
        @code = :NoPermission
      end
      do_update_response
    end

    def update_tag
        if @user.can_edit?(:update, @file)
            @code = @file.update(tag: params[:tag]) ? :Success : :Fail
        else
            @code = :NoPermission
        end
        do_update_response
    end

    def update_cover
        return if @file.file_type == Index::Workspace::Folder.file_type # 封面功能暂时只对文集和文章开放

        if @user.can_edit?(:update, @file)
            @code = @file.update(cover: params[:cover]) ? :Success : :Fail
        else
            @code = :NoPermission
        end
        do_update_response
    end

    def add_editor
      role = params[:role]
      if @user.can_edit?(:add_role, @file) && Index::Role::Edit.allow_roles.include?(role)
        editor = Index::User.find_by_id params[:user_id]
        @code = editor.add_edit_role(role, @file) ? :Success : :Fail if editor
      else
        @code ||= :NoPermission
      end
      @code ||= :Fail
      do_update_response
    end

    def remove_editor
      if @user.can_edit?(:remove_role, @file)
        editor = Index::User.find_by_id params[:user_id]
        @code = editor.remove_edit_role(file) ? :Success : :Fail if editor
      else
        @code ||= :NoPermission
      end
      @code ||= :Fail
      do_update_response
    end

    def move_dir
      # 分两种情况, 第一种把文件移动到根目录, 第二种把文件移动到另一个文件夹
      if params[:dir] == 0 # 将文件移动到根目录
        dir = 0
      else
        dir_id = params[:folder_id] || params[:corpus_id]
        dir = set_dir dir_id if dir_id
      end
      # 检查用户对目标文件的权限
      if dir == 0 || @user.can_edit?(:move_dir, dir)
        @code = @file.move_dir(dir, @user) ? :Success : :Fail
      end

      @code ||= :NoPermission
      do_update_response
    end

    # 发布
    # 文章或文集具有发布功能
    def publish
      publish = params[:is_shown]
      if [true, false].include? publish
        @code = if @user.can_edit? :publish, @file
                  @file.update(is_shown: publish) ? :Success : :Fail
                else
                  :NoPermission
                end
      end
      @code ||= :Fail
      do_update_response
    end

    def destroy
      @code = if @user.can_edit? :delete, @file
                @file.delete_files ? :Success : :Fail
              else
                :NoPermission
              end
      do_update_response
    end

    private

    def do_update_response
      respond_to do |format|
        format.json { render :show }
      end
    end
end
