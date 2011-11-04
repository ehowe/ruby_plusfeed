class FeedsController < ApplicationController
  require 'net/http'

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @feeds }
    end
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @feed = Feed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @feed }
    end
  end

  # GET /feeds/new
  # GET /feeds/new.json
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @feed }
    end
  end

  # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(params[:feed])

    respond_to do |format|
      if @feed.save
        format.html { redirect_to @feed, :notice => 'Feed was successfully created.' }
        format.json { render :json => @feed, :status => :created, :location => @feed }
      else
        format.html { render :action => "new" }
        format.json { render :json => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feeds/1
  # PUT /feeds/1.json
  def update
    @feed = Feed.find(params[:id])

    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        format.html { redirect_to @feed, :notice => 'Feed was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy

    respond_to do |format|
      format.html { redirect_to feeds_url }
      format.json { head :ok }
    end
  end

  def gid
    base_url = "https://plus.google.com/_/stream/getactivities/#{params[:id]}/"
    url_options = %Q{?sp=[1,2,"#{params[:id]}",null,null,null,null,"social.google.com",[]]}
    uri_options = URI.encode(url_options)
    url = URI.parse(base_url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.request_uri + uri_options)
    json_response = presanitize_json(http.request(request).body)
    posts = parse_feed(json_response)
    @post_data = { :author => posts[0][3], :authorimg => posts[0][18], :updated => Time.at(posts[0][5]/1000), :id => posts[0][16], :base_url => "https://plus.google.com/", :posts => posts}

    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

  private

  def parse_feed(feed)
    json = sanitize_json(feed).gsub(/nil/,'null')
    return JSON.parse json
  end

  def sanitize_json(json)
    json = json.gsub(/,,/, ',null,').gsub(/,,/, ',null,').gsub('[,','[null,').gsub(',]',',null]').gsub(/\\n/,'')
    return HTMLEntities.new.decode ActiveSupport::JSON.decode(json)[1][0]
  end

  def presanitize_json(json)
    json = json.gsub(/^.*\n\n\[/, "[")
    json = json.gsub(/\\u0026quot;/,'\"')
    return json
  end
end
