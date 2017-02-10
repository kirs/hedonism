require 'yaml'
require 'digest'

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

  def hash_for(point)
    hash = [point.fetch("lng"), point.fetch("lat")].join("_")
    Digest::MD5.hexdigest(hash)
  end
end
