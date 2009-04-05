require 'main'  # <-- your sinatra app
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'

set :environment, :test

describe 'index' do
include Sinatra::Test

  before(:each) do
    @redis = mock("Redis db")
    Redis.stub!(:new).and_return(@redis)
  end
  
  it "should render an index page" do
    get '/'
    response.should be_ok
    response.body.should include('ROOSTERBEAR')
  end
  
  it "should show login button if not logged in" do
    rack_env = {:session => {:username => nil}}
    get '/', {}, rack_env
    response.body.should include('Sign in')
  end
  
  it "should show post form if user is logged in" do
    
  end
  
  it "should add a new post" do
    @redis.should_receive(:list_range).with("username:tester:entries", 0, -1)
    get '/'
  end
end