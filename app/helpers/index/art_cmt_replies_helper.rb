module Index::ArtCmtRepliesHelper
  def attach_like_info cmts, user
    return if !user
    cmt_ids = cmts.map{|c| c.id}
    records = Index::ArtCmtRplLike.where(user_id: user.id, reply_id: cmt_ids) || []
    like_ids = records.map{|l| l.reply_id}
    cmts.each do |c|
      c.is_like =  like_ids.include?(c.id) ? true : false
    end
  end
end
