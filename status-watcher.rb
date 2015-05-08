#!/usr/bin/ruby

require "net/https"
require "uri"
require "json"

@pagerduty_url       = 'https://yourname.pagerduty.com'
@pagerduty_api_token = '123ABC'

# Memoizes get_number_of_incidents
def number_of_incidents(status)
  @_number_of_incidents ||= get_number_of_incidents(status)
end

# Always performs a GET request, no caching
def get_number_of_incidents(status)
  return -1 unless [nil, "resolved", "acknowledged", "triggered"].include? status

  root_ca      = '/etc/ssl/certs'
  uri          = URI.parse "#{@pagerduty_url}/api/v1/incidents/count"
  http         = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == 'https')
  request      = Net::HTTP::Get.new(uri.request_uri)
  request.add_field('Authorization', "Token token=#{@pagerduty_api_token}")
  request.set_form_data({"status" => status})

  if(File.directory?(root_ca) && http.use_ssl?)
    http.ca_path      = root_ca
    http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
    http.verify_depth = 5
  else
    http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
  end

  response = http.request(request)
  json = JSON.parse(response.body)

  json["total"].to_i
end

def has_triggered?
  number_of_incidents("triggered") > 0
end

def has_acknowledged?
  number_of_incidents("acknowledged") > 0
end

def has_resolved?
  number_of_incidents("resolved") > 0
end

# Light Control Logic

if has_triggered?
  system("light-control red on")
  system("light-control yellow off")
  system("light-control green off")
elsif has_acknowledged?
  system("light-control red off")
  system("light-control yellow on")
  system("light-control green off")
else
  system("light-control red off")
  system("light-control yellow off")
  system("light-control green on")
end
