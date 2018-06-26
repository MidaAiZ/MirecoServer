module Index::ArtCommentsHelper
  def attach_like_info cmts, user
    return if !user
    cmt_ids = cmts.map{|c| c.id}
    records = Index::ArtCmtLike.where(user_id: user.id, cmt_id: cmt_ids) || []
    like_ids = records.map{|l| l.cmt_id}
    cmts.each do |c|
      c.is_like =  like_ids.include?(c.id) ? true : false
    end
  end
end
