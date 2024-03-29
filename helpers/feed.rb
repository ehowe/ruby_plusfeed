class Feed
  def self.gid(params, request)
    require 'net/http'

    redis = Redis.new
    if redis[params[:id]]
      posts = JSON.parse(redis[params[:id]].gsub(/nil/,'null'))
    else
      base_url = "https://plus.google.com/_/stream/getactivities/#{params[:id]}/"
      url_options = %Q{?sp=[1,2,"#{params[:id]}",null,null,null,null,"social.google.com",[]]}
      uri_options = URI.encode(url_options)
      url = URI.parse(base_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(url.request_uri + uri_options)
      json_response = presanitize_json(http.request(req).body)
      posts = parse_feed(json_response)[1][0]
      redis[params[:id]] = posts
      redis.expire(params[:id],30*60)
    end
    if posts[0].nil?
      author = params[:id]
      authorimg = ""
      updated = Time.now
      id = params[:id]
    else
      author = posts[0][3]
      authorimg = posts[0][18]
      updated = Time.at(posts[0][5]/1000)
      id = posts[0][16]
    end
    @post_data = { :author => author, :authorimg => authorimg, :updated => updated, :id => id, :base_url => "https://plus.google.com/", :request_url => request.env['HTTP_HOST'], :posts => posts}
    return @post_data
  end

  private

  def self.parse_feed(feed)
    json = sanitize_json(feed).gsub(/nil/,'null')
    return JSON.parse json
  end

  def self.sanitize_json(json)
    json = json.gsub(/,,/, ',null,').gsub(/,,/, ',null,').gsub('[,','[null,').gsub(',]',',null]').gsub(/\\n/,'')
    return HTMLEntities.new.decode json
  end

  def self.presanitize_json(json)
    json = json.gsub(/^.*\n\n\[/, "[")
    json = json.gsub(/\\u0026quot;/,'\"')
    return json
  end
end
