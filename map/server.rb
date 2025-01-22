require "bundler/setup"
require "sinatra"
require "sinatra/json"
require "json"
require "yaml"
require "erb"

require_relative './helpers'

set :public_folder, 'public'

get "/" do
  send_file "public/admin.html"
end

post "/submit" do
  points = Helpers.read_points
  points << params

  Helpers.save_points(points)

  status 200
end

get "/points" do
  points = Helpers.get_points
  Helpers.save_points(points)

  json points
end

delete "/points/:id" do
  points = Helpers.read_points
  points.delete_if { |point| Helpers.hash_for(point) == params[:id].to_s }

  File.open("points.json", "w") do |f|
    f.write(JSON.pretty_generate(points))
  end

  status 200
end

Sinatra::Application.run!