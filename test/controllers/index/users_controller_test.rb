require 'test_helper'

class Index::UsersControllerTest < ActionController::TestCase
  setup do
    @user = index_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_user" do
    assert_difference('Index::User.count') do
      post :create, index_user: { address: @user.address, avatar: @user.avatar, birthday: @user.birthday, email: @user.email, forbidden: @user.forbidden, name: @user.name, number: @user.number, password_digest: @user.password_digest, phone: @user.phone, gender: @user.gender }
    end

    assert_redirected_to index_user_path(assigns(:index_user))
  end

  test "should show index_user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update index_user" do
    patch :update, id: @user, index_user: { address: @user.address, avatar: @user.avatar, birthday: @user.birthday, email: @user.email, forbidden: @user.forbidden, name: @user.name, number: @user.number, password_digest: @user.password_digest, phone: @user.phone, gender: @user.gender }
    assert_redirected_to index_user_path(assigns(:index_user))
  end

  test "should destroy index_user" do
    assert_difference('Index::User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to index_users_path
  end
end
