require_relative 'file_model_module'

class Index::Workspace::Article < ApplicationRecord
  include FileModel

  attr_accessor :content_id # 用来快速访问内容记录
  after_update :update_cache
  after_destroy :clear_cache, :delete_release
  # store_accessor :info, :tbp_counts, :cmt_counts, :rd_times # 点赞数/评论数/阅读次数

  belongs_to :file_seed,
             class_name: 'Index::Workspace::FileSeed',
             foreign_key: :file_seed_id

  # -----------------------文章内容------------------------ #
  has_one :inner_content,
          class_name: 'Index::Workspace::ArticleContent',
          foreign_key: :article_id

  # -----------------------发表副本------------------------ #
  has_one :release, -> { all_state },
          class_name: 'Index::PublishedArticle',
          foreign_key: :origin_id

  # ---------------------作者和作者角色---------------------- #
  has_many :editor_roles, -> { all_with_del },
           through: :file_seed,
           source: :editor_roles

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  has_many :editors,
           through: :editor_roles,
           source: :editor

  has_one :own_editor,
          through: :file_seed,
          source: :own_editor

  # -----------------------文件目录------------------------ #
  belongs_to :dir, -> { with_del },
             polymorphic: true,
             optional: true

  # -----------------------编辑评论------------------------ #
  has_many :edit_comments, as: :resource,
                           class_name: 'Index::Workspace::EditComment',
                           dependent: :destroy

  # ------------------------历史-------------------------- #
  has_many :history,
           class_name: 'Index::Workspace::HistoryArticle',
           foreign_key: :article_id,
           dependent: :destroy

  # ------------------------标星-------------------------- #
  has_many :mark_records, as: :file,
                          class_name: 'Index::Workspace::MarkRecord',
                          dependent: :destroy

  # ------------------------删除记录-------------------------- #
  has_one :trash, as: :file,
           class_name: 'Index::Workspace::Trash',
           dependent: :destroy

  # 数据验证
  validates :tag, length: { maximum: 25 }
  validates :name, presence: { message: '文件名不能为空' }, length: { maximum: 255 }
  validates :dir_type, inclusion: { in: ['Index::Workspace::Corpus', 'Index::Workspace::Folder'] }, allow_blank: true
  validate :check_state, on: [:update]

  #----------------------------域------------------------------

  scope :shown, -> { where(is_shown: true) }
  scope :root, -> { where(is_inner: false) }
  scope :unroot, -> { where(is_inner: true) }
  scope :deleted, -> { rewhere(is_deleted: true) }
  scope :undeleted, -> { where(is_deleted: false) }
  scope :with_del, -> { unscope(where: :is_deleted) }
  # 默认作用域, 不包含content字段, id降序, 未删除的文章
  default_scope { undeleted.order('index_articles.id DESC') }

  def update_content text
    if is_shown
      errors.add("文章已发表，不能再修改") and return false
    else
      content.update_text(text) and return true
    end
  end

  def content
    Index::Workspace::ArticleContent.fetch content_id || inner_content.id
  end

  def publish # 发表文章
    art = release || build_release(name: name)
    art.inner_content = inner_content
    art.author = own_editor
    begin
      ApplicationRecord.transaction do
        # 将发表文章的corpus_id指向正确文集
        if dir && dir.class == Index::Workspace::Corpus && dir.is_shown
          art.corpus = dir.release
        end
        art.save!
        update! is_shown: true
      end
    rescue
      false
    end
  end

  # ------------------------创建副本------------------------- #
  def copy target_dir = nil
    _self = self.class.new
    _self.dir = target_dir || dir
    _self.name = name + (target_dir ? "" : "副本")
    _self.create(_self.dir, own_editor, {text: content.text})
    _self
  end

  # ------------------------文件类型------------------------- #
  def file_type
    :articles
  end

  # ----------------------允许的路径类型----------------------- #
  def allow_dir_types
    [:corpuses, :folders, 0] # 目标目录文件仅允许文件夹或者空, 0代表空,即移动到根目录
  end

  @override
  def self.fetch id
    Cache.new.fetch(cache_key(id)) {
      article = self.find_by_id(id)
      article.content_id = article.inner_content.id if article
      article
    }
  end

  private

  def check_state
    if is_shown
      errors.add(:base, "文章已经发表，不能再修改") if name_changed?
    end
  end

  # 确保已发表的文章所属文集和所关联的编辑文章一致
  def after_move_dir dir
    if is_shown
      if saved_change_to_dir_id? || saved_change_to_dir_type?
        if dir.class == Index::Workspace::Corpus
          release.corpus = dir.release
          release.save
        elsif dir == nil || dir.class == Index::Workspace::Folder
          release.corpus = nil
          release.save
        end
      end
    end
  end

  # after move to trash, not really deleted
  def after_delete
    clear_cache
    if is_shown
      release.delete
      release.clear_cache
    end
  end

  def delete_release
    if is_shown
      release.delete
    else
      inner_content.destroy
    end
  end

  def after_recover
    if is_shown
      release.release
    end
  end
end
