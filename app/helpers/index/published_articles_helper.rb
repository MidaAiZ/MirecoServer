module Index::PublishedArticlesHelper
  def attach_like_info arts, user
    return if !user
    art_ids = arts.map{|a| a.id}
    records = Index::ArticleLike.where(user_id: user.id, article_id: art_ids) || []
    like_ids = records.map{|l| l.article_id}
    arts.each do |a|
      a.is_like = like_ids.include?(a.id) ? true : false
    end
  end
end
