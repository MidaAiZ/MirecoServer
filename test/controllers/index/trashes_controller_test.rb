require 'test_helper'

class Index::Workspace::TrashesControllerTest < ActionController::TestCase
  setup do
    @index_trash = index_trashes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_trashes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_trash" do
    assert_difference('Index::Workspace::Trash.count') do
      post :create, index_trash: {  }
    end

    assert_redirected_to index_trash_path(assigns(:index_trash))
  end

  test "should show index_trash" do
    get :show, id: @index_trash
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @index_trash
    assert_response :success
  end

  test "should update index_trash" do
    patch :update, id: @index_trash, index_trash: {  }
    assert_redirected_to index_trash_path(assigns(:index_trash))
  end

  test "should destroy index_trash" do
    assert_difference('Index::Workspace::Trash.count', -1) do
      delete :destroy, id: @index_trash
    end

    assert_redirected_to index_trashes_path
  end
end
