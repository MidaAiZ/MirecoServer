require 'test_helper'

class Index::CommentsControllerTest < ActionController::TestCase
  setup do
    @index_comment = index_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_comment" do
    assert_difference('Index::Comment.count') do
      post :create, index_comment: { content: @index_comment.content }
    end

    assert_redirected_to index_comment_path(assigns(:index_comment))
  end

  test "should show index_comment" do
    get :show, id: @index_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @index_comment
    assert_response :success
  end

  test "should update index_comment" do
    patch :update, id: @index_comment, index_comment: { content: @index_comment.content }
    assert_redirected_to index_comment_path(assigns(:index_comment))
  end

  test "should destroy index_comment" do
    assert_difference('Index::Comment.count', -1) do
      delete :destroy, id: @index_comment
    end

    assert_redirected_to index_comments_path
  end
end
