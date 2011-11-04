xml.instruct! :xml, :version => "1.0"
xml.feed :xmlns => "http://www.w3.org/2005/Atom" do
    xml.title "#{@post_data[:author]} - Google+ User Feed"
    xml.link :href => @post_data[:base_url] + @post_data[:id], :rel => "alternate"
    xml.link :href => '/' + @post_data[:id], :rel => "self"
    xml.id @post_data[:base_url] + @post_data[:id]
    xml.updated @post_data[:updated]
    xml.author { xml.name @post_data[:author] }
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
      xml.entry do
        xml.title ptitle[0..74]
        xml.link :href => permalink, :rel => "alternate"
        xml.updated timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
        xml.id "tag:plus.google.com," + timestamp.strftime("%Y-%m-%d") + ":/" + post_path + "/"
        xml.summary desc, :type => "html"
      end
    end
end