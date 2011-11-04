#!/usr/bin/env ruby
require 'sinatra'

class App < Sinatra::Application
  get '/' do
    @index_content = <<EOF
<div id="content">
  <div id="intro">
    <h2>
       Want a <span class="stress">feed</span> for your Google+ posts?
    </h2>
    <div id="inst">
      <p>
        Simply add a Google+ user number to the end of this site's URL to get an Atom feed of <em>public</em> posts.
      </p>
      <p>
        Example: <a href="http://#{request.env['HTTP_HOST']}/100073513220520691408">http://#{request.env['HTTP_HOST']}/<strong>100073513220520691408</strong></a>
      </p>
      <p>
        <br/>
        You can grab the source for this app on GitHub <a href="https://github.com/ehowe/ruby_plusfeed">here</a>.
      </p>
      <p>
        <em>Ruby port created by <a href="http://www.github.com/ehowe">Eugene Howe</a></em>
        <em>Original python project created by <a href="http://www.russellbeattie.com">Russell Beattie</a></em>
      </p>
    </div>
  </div>
</div>
EOF
    erb :index
  end

  get %r{/:id(.xml)?} do
    require 'builder'
    require './lib/feed.rb'
    @post_data = Feed.gid(params)

    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version => "1.0"
    xml.feed :xmlns => "http://www.w3.org/2005/Atom" do |feed|
      feed.title "#{@post_data[:author]} - Google+ User Feed"
      feed.link :href => @post_data[:base_url] + @post_data[:id], :rel => "alternate"
      feed.link :href => 'http://' + @post_data[:request_url] + '/' + @post_data[:id], :rel => "self"
      feed.id @post_data[:base_url] + @post_data[:id]
      feed.updated @post_data[:updated].strftime("%Y-%m-%dT%H:%M:%SZ")
      feed.author { xml.name @post_data[:author] }
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
    end
  end
end
