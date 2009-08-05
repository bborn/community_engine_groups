require 'pp'

class GroupphotosController < BaseController
  before_filter :login_required, :only => [:new, :edit, :update, :destroy, :create, :swfupload]
  before_filter :find_group, :only => [:new, :edit, :index, :show, :slideshow, :swfupload]
  before_filter :current_group_owner, :only => [:new, :edit, :update, :destroy, :swfupload]

  skip_before_filter :verify_authenticity_token, :only => [:create, :swfupload] #because the TinyMCE image uploader can't provide the auth token

  session :cookie_only => false, :only => :swfupload

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  cache_sweeper :taggable_sweeper, :only => [:create, :update, :destroy]    

  def recent
    @groupphotos = Groupphoto.recent.find(:all, :page => {:current => params[:page]})
  end

  # GET /groupphotos
  # GET /groupphotos.xml
  def index
    @group = Group.find(params[:group_id])

    if @group.owner == current_user
      @is_group_owner = true
    else
      @is_group_owner = false
    end

    cond = Caboose::EZ::Condition.new
    cond.group_id == @group.id
    if params[:tag_name]
      cond.append ['tags.name = ?', params[:tag_name]]
    end

    @groupphotos = Groupphoto.recent.find(:all, :conditions => cond.to_sql, :include => :tags, :page => {:current => params[:page]})

    @tags = Groupphoto.tag_counts :conditions => { :group_id => @group.id }, :limit => 20

    @rss_title = "#{AppConfig.community_name}: #{@group.name}'s groupphotos"
    @rss_url = formatted_group_groupphotos_path(@group,:rss)

    respond_to do |format|
      format.html # index.rhtml
      format.rss {
        render_rss_feed_for(@groupphotos,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'groupphotos', :action => 'index', :group_id => @group) },
             :item => {:title => :name,
                       :description => Proc.new {|groupphoto| description_for_rss(groupphoto)},
                       :link => Proc.new {|groupphoto| group_groupphoto_url(groupphoto.group, groupphoto)},
                       :pub_date => :created_at} })

      }
      format.xml { render :action => 'index.rxml', :layout => false}
    end
  end

  def manage_photos
    if logged_in?
      @group = current_group
      cond = Caboose::EZ::Condition.new
      cond.group_id == @group.id
      if params[:tag_name]
        cond.append ['tags.name = ?', params[:tag_name]]
      end

      @selected = params[:groupphoto_id]
      @groupphotos = Groupphoto.recent.find :all, :conditions => cond.to_sql, :include => :tags, :page => {:size => 10, :current => params[:page]}

    end
    respond_to do |format|
      format.js
    end
  end

  # GET /groupphotos/1
  # GET /groupphotos/1.xml
  def show
    @groupphoto = Groupphoto.find(params[:id])
    @group = @groupphoto.group
    @is_current_group = @group.eql?(current_group)
    @comment = Comment.new(params[:comment])

    @previous = @groupphoto.previous_groupphoto
    @next = @groupphoto.next_groupphoto
    @related = Groupphoto.find_related_to(@groupphoto)

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /groupphotos/new
  def new
    @group = Group.find(params[:group_id])
    @groupphoto = Groupphoto.new
    if params[:inline]
      render :action => 'inline_new', :layout => false
    end

  end

  # GET /groupphotos/1;edit
  def edit
    @groupphoto = Groupphoto.find(params[:id])
    @group = @groupphoto.group
  end

  # POST /groupphotos
  # POST /groupphotos.xml
  def create
    @group = current_group

    @groupphoto = Groupphoto.new(params[:groupphoto])
    @groupphoto.group = @group
    @groupphoto.tag_list = params[:tag_list] || ''

    respond_to do |format|
      if @groupphoto.save
        #current_user.track_group_photo_activity(:created_a_groupphoto, @groupphoto.id, "Groupphoto")
        #start the garbage collector
        GC.start
        flash[:notice] = :groupphoto_was_successfully_created.l

        format.html {
          render :action => 'inline_new', :layout => false and return if params[:inline]
          redirect_to group_groupphoto_url(:id => @groupphoto, :group_id => @groupphoto.group)
        }
        format.js {
          responds_to_parent do
            render :update do |page|
              page << "upload_image_callback('#{@groupphoto.public_filename()}', '#{@groupphoto.display_name}', '#{@groupphoto.id}');"
            end
          end
        }
      else
        format.html {
          render :action => 'inline_new', :layout => false and return if params[:inline]
          render :action => "new"
        }
        format.js {
          responds_to_parent do
            render :update do |page|
              page.alert(:sorry_there_was_an_error_uploading_the_groupphoto.l)
            end
          end
        }
      end
    end
  end

  def swfupload
    # swfupload action set in routes.rb
    @groupphoto = Groupphoto.new :uploaded_data => params[:Filedata]
    @groupphoto.group = current_group
    @groupphoto.save!

    # This returns the thumbnail url for handlers.js to use to display the thumbnail
    render :text => @groupphoto.public_filename(:thumb)
  rescue
    render :text => "Error: #{$!}", :status => 500
  end

  # PUT /groupphotos/1
  # PUT /groupphotos/1.xml
  def update
    @groupphoto = Groupphoto.find(params[:id])
    @group = @groupphoto.group
    @groupphoto.tag_list = params[:tag_list] || ''

    respond_to do |format|
      if @groupphoto.update_attributes(params[:groupphoto])
        format.html { redirect_to group_groupphoto_url(@groupphoto.group, @groupphoto) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /groupphotos/1
  # DELETE /groupphotos/1.xml
  def destroy
    @group = Group.find(params[:group_id])
    @groupphoto = Groupphoto.find(params[:id])
    if @group.avatar.eql?(@groupphoto)
      @group.avatar = nil
      @group.save!
    end
    @groupphoto.destroy

    respond_to do |format|
      format.html { redirect_to group_groupphotos_url(@groupphoto.group)   }
    end
  end

  def slideshow
    @xml_file = formatted_group_groupphotos_url( {:group_id => @group, :format => :xml}.merge(:tag_name => params[:tag_name]) )
    render :action => 'slideshow'
  end

  protected

  def description_for_rss(groupphoto)
    "<a href='#{group_groupphoto_url(groupphoto.group, groupphoto)}' title='#{groupphoto.name}'><img src='#{groupphoto.public_filename(:large)}' alt='#{groupphoto.name}' /><br />#{groupphoto.description}</a>"
  end

end
