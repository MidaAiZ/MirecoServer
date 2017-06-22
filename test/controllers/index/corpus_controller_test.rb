require 'test_helper'

class Index::Workspace::CorpusControllerTest < ActionController::TestCase
  setup do
    @corpu = index_corpus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_corpus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_corpu" do
    assert_difference('Index::Corpu.count') do
      post :create, index_corpu: { is_inner: @corpu.is_inner, name: @corpu.name, tag: @corpu.tag }
    end

    assert_redirected_to index_corpu_path(assigns(:index_corpu))
  end

  test "should show index_corpu" do
    get :show, id: @corpu
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @corpu
    assert_response :success
  end

  test "should update index_corpu" do
    patch :update, id: @corpu, index_corpu: { is_inner: @corpu.is_inner, name: @corpu.name, tag: @corpu.tag }
    assert_redirected_to index_corpu_path(assigns(:index_corpu))
  end

  test "should destroy index_corpu" do
    assert_difference('Index::Corpu.count', -1) do
      delete :destroy, id: @corpu
    end

    assert_redirected_to index_corpus_path
  end
end
