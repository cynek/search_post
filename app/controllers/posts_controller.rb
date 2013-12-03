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
    @posts = if @query.blank?
               Post.all
             else
               loader = Post.scoped
               loader = loader.by_city(query[:city]) if query[:city]
               loader.search(query[:text])
             end
  end

  def find_user
    @user = User.find(params[:post].delete(:user_id))
  end

  def query
    @query.blank? ? {} : @query
  end
end
