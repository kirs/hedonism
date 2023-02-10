require 'yaml'
require 'digest'
require "json"

module Helpers
  extend self

  def read_points
    YAML.load(File.read("points.yml"))
  end

  def get_points
    read_points.map { |point|
      point.merge("hash" => hash_for(point))
    }
  end

  def save_points(points)
    points.each do |point|
      point.delete("query")

      unless point["hash"]
        point["hash"] = hash_for(point)
      end

      point["lat"] = point["lat"].to_f
      point["lng"] = point["lng"].to_f

      if !point["name"] && point["guide"]
        point["name"] = point["guide"].sub(".md", "")
      end

      if !point["permalink"] && point["guide"]
        point["permalink"] = point["guide"].sub(".md", "").downcase.gsub(/[^a-z0-9]+/, "-")
      end

      next if point["guide"]

      guide = "#{point["full_address"].split(",").first}.md"
      if File.file?("../#{guide}")
        point["guide"] = guide
      end
    end

    File.open("points.yml", "w") do |f|
      f.write(points.to_yaml)
    end

    File.open("points.json", "w") do |f|
      f.write(JSON.pretty_generate(points))
    end
  end

  def hash_for(point)
    hash = [point.fetch("lng"), point.fetch("lat")].join("_")
    Digest::MD5.hexdigest(hash)
  end
end
