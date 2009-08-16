use Rack::OpenID
use Rack::Session::Cookie
require 'auto_html'

helpers do
  include Rack::Utils
  alias_method :escaped, :escape_html
end

set :sessions, true

before do
  @redis = Redis.new
  if session[:openid]
    @username = get_username
  end
end

def get_username
  if session[:openid]
    return @redis[session[:openid]] rescue nil
  end
end

# makes an array of hashes containing recent entries in format: [{entry, username}]
get '/' do
  @allentries = []
  @entries = @redis.list_range("recent:entries", 0, -1) rescue nil
  @entries.each do |id|
    data = {}
    data[@redis[id]] = id.match(/^(\w+)\:/)[1]
    @allentries << data
  end
  haml :index
end

get '/iphone' do
  @allentries = []
  @entries = @redis.list_range("recent:entries", 0, -1) rescue nil
  @entries.each do |id|
    data = {}
    data[@redis[id]] = id.match(/^(\w+)\:/)[1]
    @allentries << data
  end
  haml :iphone
end

get '/view/:user' do
  @entries = Array.new
  if params[:user]
    @user = params[:user]
    entry_ids = @redis.list_range("#{@user}:entries", 0, -1) rescue nil
    if entry_ids
      entry_ids.each do |id|
        @entries << @redis["#{@user}:entries:#{id}"]
      end
    end
    @entries.reverse!
  end
  haml :view
end

post '/login' do
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      email = resp.message.get_arg("http://openid.net/srv/ax/1.0", "value.email")
      id = resp.display_identifier
      session[:openid] = id
      session[:email] = email
      redirect '/pickusername'
    else
      "Aieeee: #{resp} #{request.inspect}"
    end
  else
    headers 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => params["openid_identifier"]
    )
    throw :halt, [401, 'got openid?']
  end
end

get '/pickusername' do
  @username = @redis[session[:openid]] rescue nil
  if !@username
    haml :pickusername
  else
    redirect '/'
  end
end

post '/save' do
  cleaned_username = params['username'].gsub(' ', '')
  username_exists = @redis.set_member?('usernames', cleaned_username)
  if username_exists == false
    @redis[cleaned_username] = session[:openid]
    @redis.set_add "usernames", cleaned_username
    @redis[session[:openid]] = cleaned_username
    @redis[session[:email]] = "#{cleaned_username}"
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
  @redis["#{@username}:entries:#{id}"] = params['status']
  
  recentid = @redis.incr("recententries")
  @redis.push_head("recent:entries", "#{@username}:entries:#{id}")
  @redis.list_trim 'recent:entries', 0, 25
  redirect '/'
end

get '/logout' do
  session[:openid] = nil
  redirect '/'
end

not_found do
   haml :"404"
end