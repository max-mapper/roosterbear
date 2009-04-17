require 'rubygems'
require 'sinatra'
require 'redis'
require 'rack/openid'
require 'haml'

set     :app_file,      'roosterbear.rb'
set     :environment,	:development
disable :run

run Sinatra::Application
