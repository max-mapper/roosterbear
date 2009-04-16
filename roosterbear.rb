require 'rubygems'
require 'sinatra'
require 'redis'
require 'rack/openid'
require 'haml'

use Rack::OpenID

helpers do
  include Rack::Utils
  alias_method :escaped, :escape_html
end

configure :development do
  set :sessions, true
end

before do
  @redis = Redis.new(:debug => true)
  if session[:openid]
    @username = get_username
  end
end

def get_username
  if session[:openid]
    return @redis[session[:openid]] rescue nil
  else
    return nil
  end
end

get '/' do
  @entries = Array.new
  if session[:openid]
    entry_ids = @redis.list_range("#{@username}:entries", 0, -1) rescue nil
    if entry_ids
      entry_ids.each do |id|
        @entries << @redis["#{@username}:entries:#{id}"]
      end
    end
    @entries.reverse!
  end
  haml :index
end

get '/all' do
  @allentries = []
  @entries = @redis.list_range("recent:entries", 0, -1) rescue nil
  @entries.each do |id|
    @allentries << @redis[id]
  end
  haml :all
end

post '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      id = resp.display_identifier
      session[:openid] = id
      redirect '/pickusername'
    else
      "Error: #{resp.status}"
    end
  else
    header 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => params["openid_identifier"]
    )
    throw :halt, [401, 'got openid?']
  end
end

get '/pickusername' do
  if !@username
    haml :pickusername
  else
    redirect '/'
  end
end

post '/save' do
  username_exists = @redis.set_member?('usernames', params['username'])
  if username_exists == false
    @redis[params['username']] = session[:openid]
    @redis.set_add "usernames", params['username']
    @redis[session[:openid]] = params['username']
    session[:error] = nil
  else
    session[:error] = "Username already taken. Try again"
    redirect '/pickusername'
  end
redirect '/'
end

post '/entry' do
  id = @redis.incr("entries")
  @redis.push_tail("#{@username}:entries", id)
  @redis["#{@username}:entries:#{id}"] = params['text']
  
  recentid = @redis.incr("recententries")
  @redis.push_head("recent:entries", "#{@username}:entries:#{id}")
  @redis.list_trim 'recent:entries', 0, 99
  redirect '/'
end

get '/logout' do
  session[:openid] = nil
  redirect '/'
end