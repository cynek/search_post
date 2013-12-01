class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :city
  attr_accessible :content, :image_url, :title

  define_index do
    indexes :title
    indexes :content
  end
end
