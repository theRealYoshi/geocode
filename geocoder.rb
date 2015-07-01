require "json"
require 'csv'
require "open-uri"

column_header = ['subpremise',
        'street_number',
        'route',
        'locality',
        'administrative_area_level_2',
        'administrative_area_level_1',
        'country',
        'postal_code',
        'lat',
        'lng',
        'partial_match']
NEW_FILE = "geocoded.csv"


def do_file(arr, action)
  CSV.open(NEW_FILE, action) do |row|
    row << arr
  end
end

def match?(arr, column_header)
  intersection = column_header & arr
  if !intersection.nil?
    intersection[0]
  else
    "nothing"
  end

end

geocoded = do_file(column_header, "w")
api = 'AIzaSyB3MmwC2nqCpQ1QGy5vgs-b8cHKt7n3brw'

CSV.foreach("geocoder.csv", {:headers => true, :header_converters => :symbol}) do |row|
  #change this to add "+" in spaces
  orig_address = ""
  new_address = []
  response_address = []
  addr = []
  addr << "+" + row[:address].split(" ").join("+")
  addr << row[:city].split(" ").join("+")
  addr << row[:state]
  addr << row[:zip]
  orig_address = addr.join(",+")
  q = "https://maps.googleapis.com/maps/api/geocode/json?address=#{orig_address}&key#{api}"

  JSON.parse(open(q).read)["results"].to_a.each{ |response|
    hash = {}
    response["address_components"].each{ |r|
      type = match?(r["types"].to_a, column_header)
      hash[type] = r["long_name"]
    } #long_name for addresses
    hash["lat"] = response["geometry"]["location"]["lat"] #lat
    hash["lng"] = response["geometry"]["location"]["lng"] #long
    !response["partial_match"].nil? ? hash["partial_match"] = "true" : hash["partial_match"] = "false" #partial match
    response_address << hash
  }
  puts response_address
  puts addr


end

#string for original address
#str.to_s.gsub!("+", " ")

=begin
addresses.each{ |a|
  arr = []
  column_header.each{ |type|
    if !a[type].nil?
      arr << a[type]
    else
      arr << ""
    end
  }
  do_file(arr, "a+")
}
=end
