module FileModel
    # store_accessor :info, :article_nodes, :corpus_nodes, :folder_nodes, :role_nodes

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
      res = Index::Workspace::FileSeed.move_dir(self, target_file, user)
      after_move_dir target_file
      res
    end

    # -------------------------删除文件------------------------- #
    def delete_files
      Index::Workspace::Trash.delete_files self
    end

    # --------------------------回收站-------------------------- #
    def trash
      Index::Workspace::Trash.find_by(file_id: id, file_type: self.class.name)
    end

    def delete!
      update! is_deleted: true

      files_count = 1
      if role_nodes
        roles = Index::Role::Edit.where(id: role_nodes).includes(:root_file) || []
        roles.each do |r|
          if role.is_author?
            files_count += r.root_file.delete!
          end
        end
      end
      after_delete
      files_count
    end

    def recover! # BUG
      update! is_deleted: false

      if role_nodes
        roles = Index::Role::Edit.where(id: role_nodes).includes(:root_file) || []
        roles.each do |r|
          if role.is_author?
            r.root_file.recover!
          end
        end
      end
      after_recover
    end


    # ------------------------所有子文件------------------------ #
    def files with_deleted = true
      if with_deleted
        articles = (son_articles_with_del if article_nodes.any?) || []
        corpuses = (son_corpuses_with_del if corpus_nodes.any?) || []
        folders = (son_folders_with_del if folder_nodes.any?) || []
      else
        articles = (son_articles if article_nodes.any?) || []
        corpuses = (son_corpuses if corpus_nodes.any?) || []
        folders = (son_folders if folder_nodes.any?) || []
      end

      # 返回的文件hash
      files = articles + corpuses + folders
      files_hash = { files_count: files.size, articles: articles, corpuses: corpuses, folders: folders }
      files.each do |f|
        new_files_hash = f.files with_deleted # 递归获取子文件夹的文件
        files_hash[:files_count] += new_files_hash[:files_count]
        files_hash[:articles] += new_files_hash[:articles]
        files_hash[:corpuses] += new_files_hash[:corpuses]
        files_hash[:folders] += new_files_hash[:folders]
      end

      files_hash
    end

    # ------------------------创建副本------------------------- #
    def copy target_dir = nil
      _self = self.class.new
      _self.dir = target_dir || self.dir
      _self.created_at = self.created_at + 1
      _self.name = self.name + (target_dir ? "" : "副本")

      if _self.create(_self.dir, self.own_editor)
        if self.article_nodes.any?
          self.son_articles.each do |a|
            a.copy _self
          end
        end
        if self.corpus_nodes.any?
          self.son_corpuses.each do |c|
            c.copy _self
          end
        end
        if self.folder_nodes.any?
          self.son_folders.each do |f|
            f.copy _self
          end
        end
        # # 千万不能有文件夹嵌套啊 不然就GG了 （还是先不实现这个功能了，怕爆炸）
        # if self.role_nodes.any?
        #   Index::Role::Edit.undeleted.where(id: self.role_nodes).each do |r|
        #     if r.is_author?
        #       r.root_file.copy _self
        #     end
        #   end
        # end
        # 设置root文件role dir
        if !_self.dir
          role = _self.editor_roles.own
          role.dir = self.editor_roles.own.dir
          role.save!
        end
      end
      _self
    end

    #-------------------------读取设置-------------------------- #
    def get_config uid
      (self.config || {})[uid.to_s] || {}
    end

    #---------------------------设置---------------------------- #
    def set_config uid, item, value
      self.config ||= {}
      self.config[uid] ||= {}
      self.config[uid][item] = value
      self.save
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

  #------------------------设置文件节点信息------------------------- #
  def set_file_node son
    return false if self.file_type == :articles # 文章无子节点信息
    case son.file_type
    when :articles
      self.article_nodes = self.article_nodes.push(son.id)
    when :corpuses
      self.corpus_nodes = self.corpus_nodes.push(son.id)
    when :folders
      self.folder_nodes = self.folder_nodes.push(son.id)
    end
    save!
  end

  def remove_file_node son
    return false if self.file_type == :articles # 文章无子节点信息
    case son.file_type
    when :articles
      a_ids = self.article_nodes; a_ids.delete(son.id)
      self.article_nodes = a_ids
    when :corpuses
      c_ids = self.corpus_nodes; c_ids.delete(son.id)
      self.corpus_nodes = c_ids
    when :folders
      f_ids = self.folder_nodes; f_ids.delete(son.id)
      self.folder_nodes = f_ids
    end
    save!
  end

  def set_role_node role
    return false if self.file_type == :articles # 文章无子节点信息
    self.role_nodes = self.role_nodes.push(role.id)
    save!
  end

  def remove_role_node role
    return false if self.file_type == :articles # 文章无子节点信息
    r_ids = self.role_nodes; r_ids.delete role.id
    self.role_nodes = r_ids
    save!
  end

  # 子文件节点信息
  # 自定义store_access
  def article_nodes
    info['son_articles'] || []
  end

  def corpus_nodes
    info['son_corpuses'] || []
  end

  def folder_nodes
    info['son_folders'] || []
  end

  def role_nodes
    info['role_nodes'] || []
  end

  def article_nodes= value = []
    info['son_articles'] = value.uniq
  end

  def corpus_nodes= value = []
    info['son_corpuses'] = value.uniq
    info.delete 'son_corpuses' if corpus_nodes.blank?
  end

  def folder_nodes= value = []
    info['son_folders'] = value.uniq
    info.delete 'son_folders' if folder_nodes.blank?
  end

  def role_nodes= value = []
    info['role_nodes'] = value.uniq
    info.delete 'role_nodes' if role_nodes.blank?
  end
end
