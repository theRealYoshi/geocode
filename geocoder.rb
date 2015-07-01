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


def create_file(column_header)
  CSV.open(NEW_FILE, "w") do |hdr|
    hdr << column_header
  end
end

def write_file(str)
  CSV.open(NEW_FILE,"a+") do |row|
    row << str
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

geocoded = create_file(column_header)
api = 'AIzaSyB3MmwC2nqCpQ1QGy5vgs-b8cHKt7n3brw'

str = []

CSV.foreach("geocoder.csv", {:headers => true, :header_converters => :symbol}) do |row|
  #change this to add "+" in spaces
  addr = []
  addr << "+" + row[:address].split(" ").join("+")
  addr << row[:city].split(" ").join("+")
  addr << row[:state]
  addr << row[:zip]
  str << addr.join(",+")
end

#string for original address
#str.to_s.gsub!("+", " ")

response = []
addresses = []
str.each{ |address|
  q = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key#{api}"
  #if address is not empty
  JSON.parse(open(q).read)["results"].to_a.each{ |response|
    hash = {}
    response["address_components"].each{ |r|

      type = match?(r["types"].to_a, column_header)
      hash[type] = r["long_name"]
    } #long_name for addresses
    hash["lat"] = response["geometry"]["location"]["lat"] #lat
    hash["lng"] = response["geometry"]["location"]["lng"] #long
    !response["partial_match"].nil? ? hash["partial_match"] = "true" : hash["partial_match"] = "false" #partial match
    addresses << hash
  }
}

addresses.each{ |a|
  arr = []
  column_header.each{ |type|
    if !a[type].nil?
      arr << a[type]
    else
      arr << ""
    end
  }
  write_file(arr)
}
