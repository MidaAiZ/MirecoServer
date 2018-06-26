require 'test_helper'

class Index::LikesControllerTest < ActionController::TestCase
  setup do
    @index_like = index_likes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_likes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_like" do
    assert_difference('Index::Like.count') do
      post :create, index_like: {  }
    end

    assert_redirected_to index_like_path(assigns(:index_like))
  end

  test "should show index_like" do
    get :show, id: @index_like
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @index_like
    assert_response :success
  end

  test "should update index_like" do
    patch :update, id: @index_like, index_like: {  }
    assert_redirected_to index_like_path(assigns(:index_like))
  end

  test "should destroy index_like" do
    assert_difference('Index::Like.count', -1) do
      delete :destroy, id: @index_like
    end

    assert_redirected_to index_likes_path
  end
end
