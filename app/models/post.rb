class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :city
  attr_accessible :content, :image_url, :title, :city_id, :user, :city

  define_index do
    indexes :title
    indexes :content
    indexes "'city_id_' || city_id", :as => :city_idx

    has :city_id, :type => :integer
    has :user_id, :type => :integer
    has :image_url, :type => :integer

    set_property :field_weights => {
      :title   => 2,
      :content => 1
    }
  end

  sphinx_scope :by_city do |city|
    id = city.is_a?(City) ? city.id : city
    {:conditions => {:city_idx => "city_id_#{id}"}}
  end

  sphinx_scope :with_text do |text|
    {:conditions => {:title => text, :content => text}}
  end

  sphinx_scope :group_by_city do
    {:group => 'city_id', :order => '@count desc'}
  end

  def self.loader
    Loader.new(self)
  end

  class Loader
    def initialize(klass)
      @klass = klass
      @options = {:conditions => {}}
    end

    def by_city(city)
      id = city.is_a?(City) ? city.id : city
      @options[:conditions].merge!(:city_idx => "city_id_#{id}")
      self
    end

    def with_text(text)
      @options[:conditions].merge!(:title => text, :content => text)
      self
    end

    def group_by_city
      @options[:group] = 'city_id'
      @options[:order] = '@count desc'
      self
    end

    def duplicate
      new_options = @options.dup
      clone = dup
      clone.instance_variable_set(:@options, new_options)
      clone
    end

    def result
      @options.any? ? @klass.search(@options) : @klass.search
    end
  end
end
