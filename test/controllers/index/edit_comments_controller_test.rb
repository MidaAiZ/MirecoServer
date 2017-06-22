require 'test_helper'

class Index::Workspace::EditCommentsControllerTest < ActionController::TestCase
  setup do
    @index_edit_comment = index_edit_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_edit_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_edit_comment" do
    assert_difference('Index::Workspace::EditComment.count') do
      post :create, index_edit_comment: { content: @index_edit_comment.content }
    end

    assert_redirected_to index_edit_comment_path(assigns(:index_edit_comment))
  end

  test "should show index_edit_comment" do
    get :show, id: @index_edit_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @index_edit_comment
    assert_response :success
  end

  test "should update index_edit_comment" do
    patch :update, id: @index_edit_comment, index_edit_comment: { content: @index_edit_comment.content }
    assert_redirected_to index_edit_comment_path(assigns(:index_edit_comment))
  end

  test "should destroy index_edit_comment" do
    assert_difference('Index::Workspace::EditComment.count', -1) do
      delete :destroy, id: @index_edit_comment
    end

    assert_redirected_to index_edit_comments_path
  end
end
