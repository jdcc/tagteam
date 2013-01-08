module RakeHelper
  def add_example_feeds(hub_name, feeds, user_email)
    h = Hub.find_or_initialize_by_title(:title => hub_name)
    u = User.find_by_email(user_email)

    if h.new_record?
      h.save
      u.has_role!(:owner, h)
      u.has_role!(:creator, h)
    end

    feeds.each do|feed|
      begin
        # Whenever a feed is created, it needs to have a hub associated with it
        # through HubFeed.  This way, all tags will have contexts.
        f = h.feeds.find_or_initialize_by_feed_url(feed)
        puts "Getting: #{feed}"

        if f.valid? && f.new_record?
          h.save!
          u.has_role!(:owner, f)
          u.has_role!(:creator, f)
          hf = f.hub_feeds.find_by_hub_id(h.id)
          u.has_role!(:owner, hf)
          u.has_role!(:creator, hf)
        end

      rescue Exception => e
        puts "Failed on #{feed}, error: #{e.inspect}"
      end
    end

  end
end
