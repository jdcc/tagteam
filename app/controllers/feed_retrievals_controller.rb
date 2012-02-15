class FeedRetrievalsController < ApplicationController

  before_filter :load_hub_feed

  def index
    breadcrumbs.add @hub_feed, hub_hub_feed_path(:hub_id => @hub, :id => @hub_feed)
    @feed_retrievals = @hub_feed.feed.feed_retrievals.paginate(:page => params[:page], :per_page => params[:per_page])
    render :layout => ! request.xhr?
  end

  def show
    breadcrumbs.add @hub, hub_path(@hub)
    breadcrumbs.add @hub_feed, hub_hub_feed_path(@hub, @hub_feed)
    @feed_retrieval = FeedRetrieval.find(params[:id])

    @new_items = FeedItem.paginate(:include => [:tags, :taggings, :feeds, :hub_feeds], :conditions => {:id => @feed_retrieval.new_feed_items}, :order => 'created_at desc',:page => params[:page], :per_page => params[:per_page])
    @changed_items = FeedItem.paginate(:include => [:tags, :taggings, :feeds, :hub_feeds], :conditions => {:id => @feed_retrieval.changed_feed_items}, :order => 'created_at desc',:page => params[:page], :per_page => params[:per_page])
  end

  private

  def load_hub_feed
    @hub_feed = HubFeed.find(params[:hub_feed_id])
    @hub = @hub_feed.hub
  end

end
