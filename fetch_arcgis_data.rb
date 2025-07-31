require 'net/http'
require 'json'
require 'nokogiri'
PORTAL_URL = 'https://digitalatlas.maps.arcgis.com/'
TOKEN = '.'

def fetch_data(endpoint, token)
  uri = URI("#{PORTAL_URL}/#{endpoint}")
  params = {
        'q': 'owner:aus_digitalatlas',
        'filter': 'type: "Map Service" OR type: "Feature Service" OR type: "Web Map" OR type: "Web Mapping Application"',
        'sortField': 'title',
        'sortOrder': 'asc',
        'start': 0,
        'num': 500,
        'f': 'pjson'
        # 'token': token
  }
  uri.query = URI.encode_www_form(params)

  begin
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      raise StandardError, "Invalid HTTP status: #{response.code} - #{response.message}"
    end
  rescue OpenURI::HTTPError => e
    raise StandardError, "Failed to fetch data: #{e.message}"
  rescue StandardError => e
    # Log the exception for debugging purposes
    $stderr.puts "An error occurred: #{e.message}"
    nil
  end
end

def read_data(data)

    items = data['results'] || []
    items.each do |item|
      # puts "Item ID: #{item['id']}, Title: #{item['title']}, Type: #{item['type']}"
      description = Nokogiri::HTML(item['description']).text
      item_id = item['id']
      title = item['title']
      snippet = item['snippet']
      thumbnail = item['thumbnail']
      keywords = item['typeKeywords']
      tags = item['tags']
      categories = item['categories']
      num_views = item['numViews']
      last_view = item['lastViewed']

      puts Time.at(last_view/1000).strftime("%Y-%m-%d %H:%M:%S")
    end

end

def main
  begin
    data = fetch_data('sharing/rest/search', TOKEN)
    puts "Data fetched successfully" if data
    read_data(data)
  rescue StandardError => e
    # Log the exception for debugging purposes
    $stderr.puts "An error occurred: #{e.message}"
  end
end


main()
