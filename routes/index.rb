get '/' do
  @index_content = Index.content(request)
  erb :index
end