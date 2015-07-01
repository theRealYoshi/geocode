require "json"
require "csv"
require "open-uri"

original_header = ['orig_address', 'orig_city', 'orig_state','orig_country']
column_header = ['subpremise', 'street_number','route','locality',
        'administrative_area_level_2', 'administrative_area_level_1', 'country', 'postal_code', 'lat','lng','partial_match']
NEW_FILE = File.dirname(__FILE__) + "/geocoded.csv"
CSV_FILE = File.dirname(__FILE__) +  "/geocoder.csv"

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

geocoded = do_file(original_header + column_header, "w") #create file
api = 'AIzaSyB3MmwC2nqCpQ1QGy5vgs-b8cHKt7n3brw'

CSV.foreach(CSV_FILE, {:headers => true, :header_converters => :symbol}) do |row|
  #change this to add "+" in spaces
  orig_address = ""
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
  first_hash = response_address[0]
  column_header.each{ |type|
    if !first_hash[type].nil?
      addr << first_hash[type]
    else
      addr << ""
    end
  }
  do_file(addr.map{|e| e.to_s.gsub("+", " ") }, "a+")

end
