require File.dirname(__FILE__) + "/lib/mail_fetcher"
require 'redis'

@mail = fetch("imap.gmail.com", "post@glitterbacon.com", "!glitterbacon", "993")
puts @mail.inspect

def post_entry(username, message)
  puts "Growlclucking..."
  @redis = Redis.new
  id = @redis.incr("entries")
  @redis.push_tail("#{username}:entries", id)
  @redis["#{username}:entries:#{id}"] = "#{message['subject']} #{message['body']}"

  recentid = @redis.incr("recententries")
  @redis.push_head("recent:entries", "#{username}:entries:#{id}")
  @redis.list_trim 'recent:entries', 0, 50
end

def get_username(message)
@username = @redis[message["from"]] rescue nil
  if @username.nil?
    post_entry("anonymous", message)
  else
    post_entry(@username, message)
  end
end

@mail.each do |message|
  puts message.inspect
  get_username(message)
end