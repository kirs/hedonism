require 'erb'
require 'json'

class StaticMap
  def self.points
    Helpers.get_points
  end

  def self.render
    b = binding
    tpl = ERB.new(File.read("static_map.html.erb"))
    result = tpl.result(b)

    File.open("index.html", "w") do |f|
      f.write(result)
    end
  end
end
