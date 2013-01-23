class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :login
  attr_accessor :login
  acts_as_authorization_subject :association_name => :roles, :join_table_name => :roles_users

  acts_as_tagger

  searchable do
    text :first_name, :last_name, :email, :url
    string :email
    string :first_name
    string :last_name
    string :url
    time :confirmed_at
  end

  def things_i_have_roles_on
    roles.select(:authorizable_type).where(["name = ? AND authorizable_id is not null AND authorizable_type not in('Feed')",'owner']).group(:authorizable_type).collect{|r| r.authorizable_type}.sort.collect{|r| r.constantize}
  end

  # Looks for objects of the class_of_interest owned by this user.
  def my(class_of_interest = Hub)
    roles.includes(:authorizable).find(:all, :conditions => {:authorizable_type => class_of_interest.name, :name => 'owner'}).collect{|r| r.authorizable}
  end

  # Looks for objects of the class_of_interest in a specific hub owned by this user. Not all objects have a direct relationship to a hub so this won't necesssarily work everywhere.
  def my_objects_in(class_of_interest = Hub, hub = Hub.first)
    if class_of_interest.class == Array
        class_of_interest.map! { |c| c.name }
    else
        class_of_interest = class_of_interest.name
    end
    roles.includes(:authorizable).find(:all, :conditions => {:authorizable_type => class_of_interest, :name => 'owner'}).collect{|r| r.authorizable}.reject{|o| o.hub_id != hub.id}
  end

  def my_bookmarkable_hubs
    roles.find(:all, :conditions => {:authorizable_type => 'Hub', :name => [:owner,:bookmarker]}).collect{|r| r.authorizable}
  end

  def is?(role_name, obj = nil)
    # This allows us to accept strings or arrays.
    role_names = [role_name].flatten.uniq
    gen_role_cache
    role_names.each do|r|
      if ! @role_cache["#{(obj.nil?) ? '' : obj.class.name}-#{(obj.nil?) ? '' : obj.id}-#{r}"].nil?
        return true
      end
    end
    return false
  end

  def my_bookmarking_bookmark_collections_in(hub_id)
    Feed.select('DISTINCT feeds.*').joins(:accepted_roles => [:users]).joins(:hub_feeds).where(['roles.name = ? and roles.authorizable_type = ? and roles_users.user_id = ? and hub_feeds.hub_id = ? and feeds.bookmarking_feed = ?','owner','Feed', ((self.blank?) ? nil : self.id), hub_id, true]).order('created_at desc')
  end

  def get_default_bookmarking_bookmark_collection_for(hub_id)
    bookmark_collections = my_bookmarking_bookmark_collections_in(hub_id)
    if bookmark_collections.blank?
      feed = Feed.new
      feed.bookmarking_feed = true
      feed.title = "#{email}'s bookmarks"
      feed.feed_url = 'not applicable'
      feed.save

      has_role!(:owner, feed)
      has_role!(:creator, feed)

      hf = HubFeed.new
      hf.hub_id = hub_id
      hf.feed_id = feed.id
      hf.save

      has_role!(:owner, hf)
      has_role!(:creator, hf)
      feed
    else
      bookmark_collections.first
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end


  def self.title
    'User account'
  end

  def display_name
    tmp_name = "#{first_name} #{last_name}"
    (tmp_name.blank?) ? email : tmp_name 
  end

  protected

  def gen_role_cache
    if @role_cache.nil?
      logger.warn('regenerating role cache')
      @role_cache = {}
      roles.each do|r|
        @role_cache["#{r.authorizable_type}-#{r.authorizable_id}-#{r.name}"] = 1
      end
    end
  end

end
