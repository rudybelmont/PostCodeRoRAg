require 'rgeo'
require 'rgeo/geo_json'

class Postcode < ActiveRecord::Base
  belongs_to :state
  has_many :suburbs, dependent: :delete_all
  before_save :update_max_min_lng_lat

  def self.postcode_from_point(lng, lat)
    res = []
    postcodes = where("max_lat > #{lat} and min_lat < #{lat} and max_lng > #{lng} and min_lng < #{lng}")
    point = RGeo::GeoJSON.decode('{"type":"Point","coordinates":[' + lng + ',' + lat + ']}', json_parser: :json)
    postcodes.each do |postcode|
      feature = RGeo::GeoJSON.decode(postcode.boundary, json_parser: :json)
      res << OpenStruct.new(code: postcode.code) if !feature.nil? && feature.geometry.contains?(point)
    end
    res
  end

  def update_max_min_lng_lat
    # sqllite code
    # feature = ActiveSupport::JSON.decode(boundary)

    feature = boundary
    return if feature.nil? || feature['geometry']['coordinates'].nil?

    bound = {
      max_lng: nil,
      min_lng: nil,
      max_lat: nil,
      min_lat: nil
    }

    case feature['geometry']['type'].downcase
    when 'polygon'
      bound = update_bound(bound, feature['geometry']['coordinates'][0])
    when 'multipolygon'
      feature['geometry']['coordinates'].each do |polygon|
        bound = update_bound(bound, polygon[0])
      end
    end

    self.max_lng = bound[:max_lng]
    self.min_lng = bound[:min_lng]
    self.max_lat = bound[:max_lat]
    self.min_lat = bound[:min_lat]
  end

  private

  def update_bound(bound, coordinates)
    coordinates.each do |coord|
      bound[:max_lng] = coord[0] if bound[:max_lng].nil? || coord[0] > bound[:max_lng]
      bound[:min_lng] = coord[0] if bound[:min_lng].nil? || coord[0] < bound[:min_lng]
      bound[:max_lat] = coord[1] if bound[:max_lat].nil? || coord[1] > bound[:max_lat]
      bound[:min_lat] = coord[1] if bound[:min_lat].nil? || coord[1] < bound[:min_lat]
    end

    bound
  end
end
