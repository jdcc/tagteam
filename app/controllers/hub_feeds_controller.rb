class HubFeedsController < ApplicationController
  before_filter :load_hub_feed, :except => [:index, :new, :create]
  before_filter :add_breadcrumbs, :except => [:index, :new, :create, :reschedule_immediately]
  before_filter :prep_resources

  access_control do
    allow all, :to => [:index, :show, :retrievals]
    allow :owner, :of => :hub, :to => [:new, :create, :reschedule_immediately]
    allow :owner, :of => :hub_feed, :to => [:edit, :update, :destroy]
    allow :superadmin, :hub_feed_admin
  end

  def retrievals
    breadcrumbs.add @hub_feed, hub_feed_path(@hub_feed)
    @feed_retrievals = @hub_feed.feed.feed_retrievals.paginate(:page => params[:page])
  end

  def reschedule_immediately
    feed = @hub_feed.feed
    feed.next_scheduled_retrieval = Time.now
    feed.save
    flash[:notice] = 'Rescheduled that feed to be re-indexed at the next available opportunity.'
    redirect_to @hub_feed
  rescue
    flash[:notice] = "We couldn't reschedule that feed."
    redirect_to @hub_feed
  end

  def index
    @hub_feeds = HubFeed.paginate(:order => 'updated_at desc', :page => params[:page], :per_page => params[:per_page]) 
  end

  def show
    @feed_items = @hub_feed.feed.feed_items.paginate(:order => 'updated_at desc', :page => params[:page], :per_page => params[:per_page])
  end

  def new
  end

  def create
  end

  def update
    @hub_feed.attributes = params[:hub_feed]
    respond_to do|format|
      if @hub_feed.save
        current_user.has_role!(:editor, @hub_feed)
        flash[:notice] = 'Updated that feed.'
        format.html {redirect_to hub_path(@hub)}
      else
        flash[:error] = 'Couldn\'t update that feed!'
        format.html {render :action => :new}
      end
    end
  end

  def edit
  end

  def destroy
    @hub_feed.destroy
    flash[:notice] = 'Removed that feed.'
    redirect_to(hub_path(@hub))
  rescue
    flash[:error] = "Couldn't remove that feed."
    redirect_to(hub_path(@hub))
  end

  private

  def load_hub_feed
    @hub_feed = HubFeed.find_by_id(params[:id])
    @hub = @hub_feed.hub
  end

  def prep_resources
  end

  def add_breadcrumbs
    breadcrumbs.add @hub.title, hub_path(@hub)
  end

end
