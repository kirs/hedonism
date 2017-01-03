require 'erb'
require 'json'
require_relative './helpers'

class PublicMap
  def points
    Helpers.get_points
  end

  def render
    b = binding
    tpl = ERB.new(File.read("public_map.html.erb"))
    result = tpl.result(b)

    File.open("public_map.html", "w") do |f|
      f.write(result)
    end
  end
end

PublicMap.new.render
