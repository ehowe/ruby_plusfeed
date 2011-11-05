class Index
  def self.content(request)
    redis = Redis.new
    content = <<EOF
<div id="header">
  <h1>PlusFeed</h1>
  <h2>Unofficial Google+ User Feeds</h2>
  <span id="plusone"><g:plusone size="medium" href="http://plusfeed.xtreme-computers.net"></g:plusone></span>
</div>
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
        You can grab the source for this app on GitHub <a href="https://github.com/ehowe/ruby_plusfeed">here</a>.
      </p>
      <p>
        After each initial request, the data will be cached for 30 minutes.
      </p>
      <p>
        <em>Ruby port created by <a href="http://www.github.com/ehowe">Eugene Howe</a></em><br/>
        <em>Original python project created by <a href="http://www.russellbeattie.com">Russell Beattie</a></em>
      </p>
    </div>
  </div>
</div>
EOF
    if redis['index']
      index_content = redis['index']
    else
      index_content = content
      redis['index'] = content
      redis.persist('index')
    end
    return index_content
  end
end