class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :city
  attr_accessible :content, :image_url, :title, :city_id

  define_index do
    indexes :title
    indexes :content
    indexes "'city_id_' || city_id", :as => :city_idx

    has :city_id
    has :user_id
    has :image_url

    set_property :field_weights => {
      :title   => 2,
      :content => 1
    }
  end

  sphinx_scope :by_city do |city|
    id = city.is_a?(City) ? city.id : city
    {:conditions => {:city_idx => "city_id_#{id}"}}
  end
end
