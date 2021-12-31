require "bundler/setup"
require "sinatra"
require "sinatra/json"
require "pry"
require "json"
require "yaml"
require "erb"

require_relative './helpers'

get "/" do
  send_file "public/admin.html"
end

post "/submit" do
  points = Helpers.read_points
  points << params

  File.open("points.yml", "w") do |f|
    f.write(points.to_yaml)
  end

  status 200
end

get "/points" do
  points = Helpers.get_points

  points.each do |point|
    point.delete("hash")
    next if point["guide"]

    guide = "#{point["full_address"].split(",").first}.md"
    puts guide
    if File.file?("../#{guide}")
      point["guide"] = guide
    end
  end

  File.open("points.yml", "w") do |f|
    f.write(points.to_yaml)
  end

  json points
end

delete "/points/:id" do
  points = Helpers.read_points
  points.delete_if { |point| Helpers.hash_for(point) == params[:id].to_s }

  File.open("points.yml", "w") do |f|
    f.write(points.to_yaml)
  end

  status 200
end
