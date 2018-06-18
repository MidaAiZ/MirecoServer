class Manage::MainController < ManageController
  def user_count
    render_res fetch_user_count
  end

  def alive_count
    @unit = params[:unit]
    if ![:day, :week, :month, :year].include?(@unit)
      @unit = :day
    end
    render_res fetch_alive_count
  end

  def file_count
    render_res fetch_file_count
  end

  def view_count
    render_res fetch_view_count
  end

  private

  def render_res data
    render json: data
  end

  def fetch_user_count
    Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      {
        user_count: Index::User.count,
        new_count: Index::User.new_today.count,
        today_alive_count: Index::LoginRecord.day_alive.count
      }
    end
  end

  def fetch_alive_count
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      t_s = Time.now.midnight
      t_e = Time.now
      map = {}
      7.times do |i|
        map["alive_count_" + i.to_s] = Index::LoginRecord.alive(t_time(t_s, i + 1), i == 0 ? t_e : t_time(t_e, i)).count
      end
      map
    end
  end

  def fetch_file_count
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      art_count = Index::Workspace::Article.count
      cor_count = Index::Workspace::Corpus.count
      fol_count = Index::Workspace::Folder.count
      art_released_count = Index::PublishedArticle.count
      cor_released_count = Index::PublishedCorpus.count
      {
        article_count: art_count,
        corpus_count: cor_count,
        folder_count: fol_count,
        article_released_count: art_released_count,
        corpus_released_count: cor_released_count
      }
    end
  end

  def fetch_view_count
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      {
        view_count: Index::ArticleReadRecord.count,
        today_view_count: Index::ArticleReadRecord.new_today.count
      }
    end
  end

  def t_time t, num
    case @unit
    when :day
      return t.days_ago(num).beginning_of_day
    when :week
      return t.weeks_ago(num).beginning_of_week
    when :month
      return t.months_ago(num).beginning_of_month
    when :year
      return t.years_ago(num).beginning_of_year
    else
      return Time.now
    end
  end
end
