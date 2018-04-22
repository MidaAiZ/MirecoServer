module FileModel
    # ----------------------判断是否是协作文件--------------------- #
    def is_cooperate?
      file_seed.editors_count > 1
    end

    #---------------------------标星--------------------------- #
    def is_marked id
      (marked_u_ids || []).include? id
    end

    # ----------------------判断是否为根文件--------------------- #
    def is_root?
      file_seed.root_file_id == id && file_seed.root_file_type == itself.class.name
    end

    # ----------------------创建并设置目录----------------------- #
    def create(target_dir, user, attrs = {})
      Index::Workspace::FileSeed.create(self, target_dir, user, attrs)
    end

    # -------------------------移动文件------------------------- #
    def move_dir(target_file, user)
      res = Index::Workspace::FileSeed.move_dir self, target_file, user
      afetr_move_dir target_file
      res
    end

    # -------------------------删除文件------------------------- #
    def delete_files(user)
      Index::Workspace::Trash.delete_files(self, user)
    end

    # --------------------------回收站-------------------------- #
    def trash
      Index::Workspace::Trash.find_by(file_id: id, file_type: self.class.name)
    end

    def delete! user
      update! is_deleted: true

      files = []
      files_count = 1
      files.concat son_articles if info['articles']
      files.concat son_corpuses if info['corpuses']
      files.concat son_folders if info['folders']
      files.each do |f| # 遍历删除
        files_count += f.delete! user
      end
      if info['son_roles']
        roles = user.editor_roles.where(id: info['son_roles']).includes(:root_file)
        roles.each do |r|
          if role.is_author?
            files_count += r.root_file.delete! user
          end
        end
      end
      clear_cache
      return files_count
    end

    def recover! user
      update! is_deleted: false
      files = []
      files.concat son_articles_with_del if info['articles']
      files.concat son_corpuses_with_del if info['corpuses']
      files.concat son_folders_with_del if info['folders']
      files.each do |f| # 遍历删除
        f.recover! user
      end
      if info['son_roles']
        roles = user.editor_roles.where(id: info['son_roles']).includes(:root_file)
        roles.each do |r|
          if role.is_author?
            r.root_file.recover! user
          end
        end
      end
    end

    #---------------------------搜索---------------------------- #
    def self.filter(cdt = {}, offset = 0, limit = 100)
      allow_hash = { 'name' => 'LIKE', 'tag' => 'LIKE' } # 允许查询的字段集
      keys = allow_hash.keys
      sql_arr = []
      cdt.keys.each do |key|
        if keys.include? key
          sql_arr.push "\"#{key}\" #{allow_hash[key]} \'#{cdt[key]}\'" unless cdt[key].blank?
        end
      end
      sql = ''
      sql_arr.each do |s| # 拼接条件
        sql += s
        sql += 'OR' if s != sql_arr.last
      end
      sql.blank? ? nil : self.where(sql).offset(offset).limit(limit)
    end

end
