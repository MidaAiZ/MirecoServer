# 这是一个视图噢
# 合并了用户文章、文集、文件夹以及相关的角色和file_seed信息
# 目前处于尝试阶段，暂时不决定正式使用，性能比较低

class Index::Workspace::CoFile < ApplicationRecord
  self.table_name = 'index_co_files'

  belongs_to :editor,
            class_name: 'Index::User',
            foreign_key: :u_id

  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :seed_id

  has_one :release, -> { all_state },
           class_name: 'Index::PublishedArticle',
           foreign_key: :release_id

  belongs_to :dir, -> { with_del },
              polymorphic: true,
              optional: true

  scope :order_by_rtime, -> { order(r_created_at: :desc) }
  scope :order_by_ftime, -> { order(f_created_at: :desc) }
  scope :own, -> { where(role: :own) }
  scope :root, -> { where(dir_id: nil).where(r_dir: nil) }
  scope :unroot, -> { where.not(dir_id: nil) }
  # default_scope {  }

  #--------------------------是否发表------------------------- #
  def is_shown
    !!release_id
  end

  #---------------------------标星--------------------------- #
  def is_marked id
    (marked_u_ids || []).include? id
  end

end
