require 'test_helper'

class Index::ThumbUpsControllerTest < ActionController::TestCase
  setup do
    @index_thumb_up = index_thumb_ups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_thumb_ups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_thumb_up" do
    assert_difference('Index::ThumbUp.count') do
      post :create, index_thumb_up: {  }
    end

    assert_redirected_to index_thumb_up_path(assigns(:index_thumb_up))
  end

  test "should show index_thumb_up" do
    get :show, id: @index_thumb_up
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @index_thumb_up
    assert_response :success
  end

  test "should update index_thumb_up" do
    patch :update, id: @index_thumb_up, index_thumb_up: {  }
    assert_redirected_to index_thumb_up_path(assigns(:index_thumb_up))
  end

  test "should destroy index_thumb_up" do
    assert_difference('Index::ThumbUp.count', -1) do
      delete :destroy, id: @index_thumb_up
    end

    assert_redirected_to index_thumb_ups_path
  end
end
