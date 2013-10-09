require 'nokogiri'
require 'addressable/uri'
require 'rest-client'
require 'json'

class Place

  attr_accessor :lat_long, :address, :name

  def initialize(params = {})
    @lat_long = params[:lat_long]
    @address = params[:address]
    @name = params[:name]
    @lat_long = get_lat_long
  end

  def get_directions(destination, mode = "walking")
    #return directions as a string
    params = {
         :origin => @lat_long.join(','),
         :destination => destination.get_lat_long.join(','),
         :sensor => "false",
         :mode => mode
       }

    endpoint = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/directions/json"
    ).to_s


    parsed = JSON.parse(RestClient.get(endpoint, :params => params))
    steps = parsed["routes"][0]["legs"][0]["steps"]
    directions = []
    directions << "Directions from: #{@address} to: #{destination.name} located at: #{
          destination.address}:\n"
    steps.each do |step_hash|
      directions << Nokogiri::HTML(step_hash['html_instructions']).text
    end

    puts directions.join("\n").gsub("Destination","\nDestination")
  end


  def find_nearby(target)
    #return an array of places matching the queried objects description
    params = {
         :key => 'AIzaSyBG-J1yLdj1gy_yTXX0F13P0X1Hyh2E_Ls',
         :location => @lat_long.join(','),
         :rankby => 'distance',
         :sensor => "false",
         :keyword => target
       }

    endpoint = Addressable::URI.new(
      :scheme => "https",
      :host => "maps.googleapis.com",
      :path => "maps/api/place/nearbysearch/json"
    ).to_s

    parsed = JSON.parse(RestClient.get(endpoint, :params => params))
    first = parsed["results"][0] #the object
    new_lat_long = first["geometry"]["location"].values
    new_name = first["name"]
    new_address = first["vicinity"]
    result = Place.new({
        :lat_long => new_lat_long,
        :address => new_address,
        :name => new_name
      })

  end

  def get_lat_long
    return @lat_long if @lat_long
    params = { :address => @address, :sensor => "false" }
    endpoint = Addressable::URI.new(
      :scheme => "https",
      :host => "www.google.com",
      :path => "maps/api/geocode/json"
    ).to_s

    parsed = JSON.parse(RestClient.get(endpoint, :params => params))
    puts parsed
    @lat_long = parsed["results"][0]["geometry"]["location"].values
  end
end
