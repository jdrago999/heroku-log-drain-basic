
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'sinatra'
  gem 'nokogiri'
  gem 'puma'
  gem 'aws-sdk-cloudwatchlogs'
end

set :port, ENV.fetch('PORT', 4567)
set :bind, '0.0.0.0'
http_username, http_password = ENV.fetch('USER'), ENV.fetch('PASS')

aws = Aws::CloudWatchLogs::Client.new

use Rack::Auth::Basic do |username, password|
  username == http_username && password == http_password
end

post '/(**log_group)/(**log_stream_name)' do
  # Parses log format like this:
  # 89 <45>1 2023-03-18T00:01:28.723822+00:00 host heroku web.1 - State changed from down to up
  log_events = []
  request.body.read.split(/\r?\n/).map{|line| line.match(%r{(.+?)\s+(.+?)\s+(\S+)\s+(.+)\Z})[3..4] }.map do |set|
    time, raw_message = *set
    message = JSON.parse(raw_message) rescue raw_message
    log_event = {
      # AWS Wants timestamps as integers = unix time * 1000:
      timestamp: DateTime.rfc3339(time).to_time.to_i * 1000,
      message: message
    }
    log_events << log_event
  end

  warn '////// LOGGING THIS: %s' % log_events.to_json
  aws.put_log_events(
    log_group_name: params['log_group'],
    log_stream_name: params['log_stream_name'],
    log_events: log_events
  )
  200
end

Sinatra::Application.run!
