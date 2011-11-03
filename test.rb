require 'json'

file = File.open("responsetxt.txt").readlines.first
file = file.gsub('\\','')
puts file
json = JSON.parse(file)
puts json.inspect
