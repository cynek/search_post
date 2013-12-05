class PostsController < ApplicationController
  before_filter :find_user, :only => :create
  helper_method :query

  def new
    @post = Post.new
  end

  def create
    @post = @user.posts.build(params[:post])
    if @post.save
      redirect_to posts_url
    else
      render :new
    end
  end

  def index
    @query = params[:query]
    loader = Post.scoped
    loader.by_city(query[:city]) if query[:city].present?
    loader.with_text(query[:text]) if query[:text].present?
    @cities = loader.duplicate.group_by_city.result
    @posts = loader.result
  end

  def find_user
    @user = User.find(params[:post].delete(:user_id))
  end

  def query
    @query.blank? ? {} : @query
  end
end
