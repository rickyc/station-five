require 'rubygems'
require 'sinatra'
require 'haml'
require 'coffee-script'
require 'sass'
require 'yaml'
require 'dm-core'  
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || {
 :adapter  => 'mysql',
 :host     => 'localhost',
 :username => 'root' ,
 :password => '',
 :database => 'sinatra_station_five_development'
})

class Player
  include DataMapper::Resource  

  # Properties
  property :id,                 Serial
  property :name,               String,  :required => true
  property :score,              Integer, :required => true, :default => 0
  property :time,               Integer, :required => true, :default => 0
  property :created_at,         DateTime
end

Dir["config/initializers/**/*.rb"].each do |file_path|
  require File.join(Dir.pwd, file_path)
end

get '/' do
  haml :index, :format => :html5
end

get '/highscore' do
  @players = Player.all :order => [:score.desc]
  haml :highscore
end

get '/:javascript.js' do |javascript|
  coffee :"/assets/javascripts/#{javascript}"
end

get '/:stylesheet.css' do |stylesheet|
  sass :"/assets/stylesheets/#{stylesheet}"
end

post '/player' do
  Player.create(:name => params[:name], :score => params[:score], :time => params[:time], :created_at => Time.now)
end


helpers do
  def h(text)
    escape_once(text)
  end

  def partial( page, variables={} )
    haml page.to_sym, {layout:false}, variables
  end
end


# Database Logic
DataMapper.finalize

#DataMapper.auto_migrate!
configure :development do
  DataMapper.auto_upgrade!
end
