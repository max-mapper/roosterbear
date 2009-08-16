require File.dirname(__FILE__) + "/lib/mail_fetcher"
require 'redis'
@image_path = "/home/roosterbear/roosterbear/public/uploads"
@posts = fetch("imap.gmail.com", "post@glitterbacon.com", "!glitterbacon", "993", @image_path)
@redis = Redis.new

def post_entry(username, message)
  puts "Growlclucking..."
  id = @redis.incr("entries")
  @redis.push_tail("#{username}:entries", id)
  @redis["#{username}:entries:#{id}"] = message
  
  recentid = @redis.incr("recententries")
  @redis.push_head("recent:entries", "#{username}:entries:#{id}")
  @redis.list_trim 'recent:entries', 0, 25
end

@posts.each do |post|
  post.each do |from, message|
    puts "From: #{from}"
    user = @redis["#{from}"] rescue nil
    @username = @redis["#{user}"] rescue nil
    if @username.nil?
      post_entry("anonymous", message)
    else
      post_entry(@username, message)
    end
  end
end