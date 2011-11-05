get '/:id' do
  @post_data = Feed.gid(params, request)

  xml = Builder::XmlMarkup.new
  xml.instruct! :xml, :version => "1.0"
  xml.feed :xmlns => "http://www.w3.org/2005/Atom" do |feed|
    feed.title "#{@post_data[:author]} - Google+ User Feed"
    feed.link :href => @post_data[:base_url] + @post_data[:id], :rel => "alternate"
    feed.link :href => 'http://' + @post_data[:request_url] + '/' + @post_data[:id], :rel => "self"
    feed.id @post_data[:base_url] + @post_data[:id]
    feed.updated @post_data[:updated].strftime("%Y-%m-%dT%H:%M:%SZ")
    feed.author { xml.name @post_data[:author] }
    unless @post_data[:posts].empty?
      @post_data[:posts].each do |post|
        post_path = post[21]
        permalink = @post_data[:base_url] + post_path
        timestamp = Time.at(post[5]/1000)
        unless post[47].nil?
          desc = post[47]
        else
          desc = post[4]
        end
        if post[44]
          desc = desc + ' <br/><br/><a href="' + @post_data[:base_url] + post[44][1] + '">' + post[44][0] + '</a> originally shared this post:'
        end
        unless post[66].empty?
          unless post[66][0].nil?
            unless post[66][0][1].nil?
              desc = desc + ' <br/><br/><a href="' + post[66][0][1] + '">' + post[66][0][3] + '</a>'
            end
            unless post[66][0][6].nil?
              unless post[66][0][6][0].nil?
                unless post[66][0][6][0][1].nil?
                  desc = desc + ' <p><img src="http:' + post[66][0][6][0][2] + '"/></p>'
                else
                  desc = desc + ' <a href="' + post[66][0][6][0][8] = '">' + post[66][0][6][0][8] + '</a>'
                end
              end
            end
          end
        end
        desc = permalink if desc == ''
        ptitle = HTMLEntities.new.decode(desc).gsub(/<.*?>/,'')
        feed.entry do |entry|
          entry.title ptitle[0..74]
          entry.link :href => permalink, :rel => "alternate"
          entry.updated timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
          entry.id "tag:plus.google.com," + timestamp.strftime("%Y-%m-%d") + ":/" + post_path + "/"
          entry.summary desc, :type => "html"
        end
      end
    else
      timestamp = Time.now
      feed.entry do |entry|
        entry.title "No public feeds for #{@post_data[:id]}"
        entry.link :href => @post_data[:base_url] + @post_data[:id]
        entry.updated timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
        entry.id "tag:plus.google.com," + timestamp.strftime("%Y-%m-%d") + ":/" + @post_data[:id] + "/"
        entry.summary "This feed contains no public posts", :type => "html"
      end
    end
  end
end