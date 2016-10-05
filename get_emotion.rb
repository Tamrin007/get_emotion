require 'net/http'
require 'json'
require 'csv'

uri = URI('https://api.projectoxford.ai/emotion/v1.0/recognize')
uri.query = URI.encode_www_form({
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/octet-stream'
# Request headers
request['Ocp-Apim-Subscription-Key'] = '849f204323c941fda27ef4b09068a07e'
# get jpg files in directory
images = Dir.glob("*.png")
# sort by number
images = images.sort_by{|file| file[/\d+/].to_i}

scores = []
headers = []

images.each { |image|
    # Request body
    request.body = File.binread(image)

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    score = JSON.parse(response.body)[0]['scores']
    headers = score.keys
    scores.push(score.values)
}

CSV.open("result.csv", "w", :headers => headers.insert(0, "time"), :write_headers => true) do |csv|
    scores.each_with_index { |e, i|
        e.insert(0, i * 3)
        csv << e
    }
end
