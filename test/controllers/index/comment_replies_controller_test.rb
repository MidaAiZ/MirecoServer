require 'test_helper'

class Index::CommentRepliesControllerTest < ActionController::TestCase
  setup do
    @index_comment_reply = index_comment_replies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_comment_replies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_comment_reply" do
    assert_difference('Index::CommentReply.count') do
      post :create, index_comment_reply: {  }
    end

    assert_redirected_to index_comment_reply_path(assigns(:index_comment_reply))
  end

  test "should show index_comment_reply" do
    get :show, id: @index_comment_reply
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @index_comment_reply
    assert_response :success
  end

  test "should update index_comment_reply" do
    patch :update, id: @index_comment_reply, index_comment_reply: {  }
    assert_redirected_to index_comment_reply_path(assigns(:index_comment_reply))
  end

  test "should destroy index_comment_reply" do
    assert_difference('Index::CommentReply.count', -1) do
      delete :destroy, id: @index_comment_reply
    end

    assert_redirected_to index_comment_replies_path
  end
end
