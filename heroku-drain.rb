
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
  time, message = %r{^(.+?)\s+(.+?)\s+(\S+)\s+(.+?)$}.match(request.body.read).to_a[3..4]
  log_event = {
    # AWS Wants timestamps as integers = unix time * 1000:
    timestamp: DateTime.rfc3339(time).to_time.to_i * 1000,
    message: message
  }
  aws.put_log_events(
    log_group_name: params['log_group'],
    log_stream_name: params['log_stream_name'],
    log_events: [log_event]
  )
  200
end

Sinatra::Application.run!
