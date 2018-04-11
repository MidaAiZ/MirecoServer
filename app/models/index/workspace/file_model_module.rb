module FileModel
    # ----------------------判断是否是协作文件--------------------- #
    def is_cooperate?
        file_seed.editors_count > 1
    end

    # ----------------------------赞---------------------------- #
    def thumb_ups
      Index::ThumbUp.get(self)
    end

    # ---------------------------赞数--------------------------- #
    def thumb_up_counts
      Index::ThumbUp.counts(self)
    end

    # --------------------------判断赞-------------------------- #
    def has_thumb_up?(user)
      Index::ThumbUp.has?(self, user)
    end

    # -------------------------点赞信息------------------------- #
    def thumb_up_info(user)
      Index::ThumbUp.counts_and_has?(self, user)
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
      Index::Workspace::FileSeed.move_dir self, target_file, user
    end

    # -------------------------删除文件------------------------- #
    def delete_files(user = nil)
      Index::Workspace::Trash.delete_files(self, user)
    end

    # --------------------------回收站-------------------------- #
    def trash
      Index::Workspace::Trash.find_by file_id: id, file_type: self.class.name
    end

    def delete_thumb_up
      # Index::ThumbUp.destroy self
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
