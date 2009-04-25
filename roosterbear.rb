use Rack::OpenID
use Rack::Session::Cookie

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

def auto_html(text)
  text.gsub(/http:\/\/.+\.(jpg|gif|png)/i) do |match|
    return "<center><img src='#{match}' alt='' width='600'/></center>"
  end
  text.gsub(/http:\/\/(www.)?vimeo\.com\/([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/) do
    vimeo_id = $2
    return %{<center><object width="600" height="320"><param name="allowfullscreen" value="true" /><param name="allowscriptaccess" value="always" /><param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=#{vimeo_id}&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=00adef&amp;fullscreen=1" /><embed src="http://vimeo.com/moogaloop.swf?clip_id=#{vimeo_id}&amp;server=vimeo.com&amp;show_title=0&amp;show_byline=0&amp;show_portrait=0&amp;color=00adef&amp;fullscreen=1" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" width="600" height="320"></embed></object></center>}    
  end
  text.gsub(/http:\/\/(www.)?youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/) do
    youtube_id = $2
    return %{<center><object width="600" height="320"><param name="movie" value="http://www.youtube.com/v/#{youtube_id}"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/#{youtube_id}" type="application/x-shockwave-flash" wmode="transparent" width="600" height="320"></embed></object></center>}
  end
  return text
end

def get_username
  if session[:openid]
    return @redis[session[:openid]] rescue nil
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
    data = {}
    data[@redis[id]] = id.match(/^(\w+)\:/)[1]
    @allentries << data
  end
  haml :all
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
      id = resp.display_identifier
      session[:openid] = id
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
  @redis.list_trim 'recent:entries', 0, 99
  redirect '/'
end

get '/logout' do
  session[:openid] = nil
  redirect '/'
end


not_found do
   haml :"404"
end
