require 'test_helper'

class Index::Workspace::HistoryArticlesControllerTest < ActionController::TestCase
  setup do
    @history_article = index_history_articles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:index_history_articles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create index_history_article" do
    assert_difference('Index::Workspace::HistoryArticle.count') do
      post :create, index_history_article: { content: @history_article.content, tag: @history_article.tag, title: @history_article.title }
    end

    assert_redirected_to index_history_article_path(assigns(:index_history_article))
  end

  test "should show index_history_article" do
    get :show, id: @history_article
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @history_article
    assert_response :success
  end

  test "should update index_history_article" do
    patch :update, id: @history_article, index_history_article: { content: @history_article.content, tag: @history_article.tag, title: @history_article.title }
    assert_redirected_to index_history_article_path(assigns(:index_history_article))
  end

  test "should destroy index_history_article" do
    assert_difference('Index::Workspace::HistoryArticle.count', -1) do
      delete :destroy, id: @history_article
    end

    assert_redirected_to index_history_articles_path
  end
end
