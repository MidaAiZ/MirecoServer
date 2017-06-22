require 'test_helper'

class Index::Workspace::ArticlesControllerTest < ActionController::TestCase
  setup do
    @article = index_articles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_articles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_article" do
    assert_difference('Index::Workspace::Article.count') do
      post :create, index_article: { content: @article.content, tag: @article.tag, title: @article.title }
    end

    assert_redirected_to index_article_path(assigns(:index_article))
  end

  test "should show index_article" do
    get :show, id: @article
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @article
    assert_response :success
  end

  test "should update index_article" do
    patch :update, id: @article, index_article: { content: @article.content, tag: @article.tag, title: @article.title }
    assert_redirected_to index_article_path(assigns(:index_article))
  end

  test "should destroy index_article" do
    assert_difference('Index::Workspace::Article.count', -1) do
      delete :destroy, id: @article
    end

    assert_redirected_to index_articles_path
  end
end
