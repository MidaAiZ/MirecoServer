require 'test_helper'

class Index::Workspace::FoldersControllerTest < ActionController::TestCase
  setup do
    @folder = index_folders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_folders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_folder" do
    assert_difference('Index::Workspace::Folder.count') do
      post :create, index_folder: { is_deleted: @folder.is_deleted, is_marked: @folder.is_marked, is_shown: @folder.is_shown, name: @folder.name, tag: @folder.tag }
    end

    assert_redirected_to index_folder_path(assigns(:index_folder))
  end

  test "should show index_folder" do
    get :show, id: @folder
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @folder
    assert_response :success
  end

  test "should update index_folder" do
    patch :update, id: @folder, index_folder: { is_deleted: @folder.is_deleted, is_marked: @folder.is_marked, is_shown: @folder.is_shown, name: @folder.name, tag: @folder.tag }
    assert_redirected_to index_folder_path(assigns(:index_folder))
  end

  test "should destroy index_folder" do
    assert_difference('Index::Workspace::Folder.count', -1) do
      delete :destroy, id: @folder
    end

    assert_redirected_to index_folders_path
  end
end
