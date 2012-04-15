require 'rubygems'
require 'sinatra'
require 'haml'
require 'coffee-script'
require 'sass'
require 'yaml'

Dir["config/initializers/**/*.rb"].each do |file_path|
  require File.join(Dir.pwd, file_path)
end

get '/' do
  haml :index, :format => :html5
end

get '/:javascript.js' do |javascript|
  coffee :"/assets/javascripts/#{javascript}"
end

get '/:stylesheet.css' do |stylesheet|
  sass :"/assets/stylesheets/#{stylesheet}"
end

helpers do
  def h(text)
    escape_once(text)
  end

  def partial( page, variables={} )
    haml page.to_sym, {layout:false}, variables
  end
end
