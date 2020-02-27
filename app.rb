# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

restaurants_table = DB.from(:restaurants)
comments_table = DB.from(:comments)

get "/" do
    @title = "Home Page"
    puts "params: #{params}"
    pp restaurants_table.all.to_a
    @restaurants = restaurants_table.all.to_a
    view "restaurants"
end 

get "/restaurants/:id" do
    puts "params: #{params}"

    pp restaurants_table.where(id: params[:id]).to_a[0]
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    @title = "#{@restaurant[:name]}"
    view "restaurant"
end

get "/restaurants/:id/reviews/new" do
    puts "params: #{params}"

    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    view "new_review"
end
