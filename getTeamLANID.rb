require 'net/http'
require 'json'

def httpCall(url)
  resp = Net::HTTP.get_response(URI.parse(url))
  if resp.code.to_i != 200
    puts "Error occurred. Exciting. HTTP status code: #{resp.code}. HTTP message: #{resp.message}."
  end
  JSON.parse(resp.body)
end

def sherlock_group(groupName)
  if groupName == ''
    exit(1)
  end
  groupName = groupName.to_s.gsub(' ', '%20')
  url = "https://sherlock-api.nordstrom.net/api/v1/group/#{groupName}"
  httpCall(url)
end

def sherlock_name(name)
  name = name.to_s.gsub(' ', '%20')
  url = "https://sherlock-api.nordstrom.net/api/v1/search/#{name}"
  httpCall(url)
end

def sherlock_lan(user)
  if user != ''
    url = "https://sherlock-api.nordstrom.net/api/v1/user/#{user}"
    httpCall(url)
  end
end

def get_name_from_lanid(lanID)
  lanID.each do |id|
    puts "#{id}=> #{sherlock_lan(id)['cn']}"
  end
end

parsed = sherlock_group('itpcmall')
listOfNames = parsed['members']['users']

lanID = []
listOfNames.each do |name|
  # if name.to_s.include?('Harman') || name.to_s.include?('Will')
  #   next
  # end
  name.to_s.sub!(',','')
  id = sherlock_name(name)['users'][0]['lanID']
  puts id
  lanID.push(id)
end

get_name_from_lanid(lanID)

# puts lanID
# listOfNames= `sherlock_group itpcmall |jq '.members.users[]' |  sed 's/"//g' | sed 's/,//g'`
