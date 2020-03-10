# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"  
require "geocoder"                                                              #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

restaurants_table = DB.from(:restaurants)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

# Related to twilio:
account_sid = "AC11abad30a09fe904e18de7564f60b7f1"
auth_token = "d72c01da2b6d4026e7b5b92b4f40fcf8"
client = Twilio::REST::Client.new(account_sid, auth_token)


before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end


get "/" do
    @title = "Home Page"
    pp restaurants_table.all.to_a
    @restaurants = restaurants_table.all.to_a
    view "restaurants"
end 

get "/restaurants/:id" do
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(restaurant_id: @restaurant[:id])
    @like_count = reviews_table.where(restaurant_id: @restaurant[:id]).sum(:enjoying)
    @users_table = users_table

    results = Geocoder.search(@restaurant[:location])
    lat_lng = results.first.coordinates
    lat = lat_lng[0]
    long = lat_lng[1]
    @lat_long = "#{lat},#{long}"
    
    @title = "#{@restaurant[:name]}"
    view "restaurant"
end

get "/restaurants/:id/reviews/new" do
    @restaurant = restaurants_table.where(id: params[:id]).to_a[0]
    @title = "New Review"
    view "new_review"
end


get "/restaurants/:id/reviews/create" do
    puts params
    @restaurant = restaurants_table.where(id: params["id"]).to_a[0]
    
    if  @current_user == nil
        view "create_review_failed"
    else
        if reviews_table.where(user_id: @current_user[:id], restaurant_id: @restaurant[:id]).to_a[0] != nil
            view "create_review_failed"
        else
            reviews_table.insert(restaurant_id: params["id"],
                            user_id: session["user_id"],
                            enjoying: params["enjoying"],
                            reviews: params["reviews"])
            view "create_review"
        end
    end
end


get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    user = users_table.where(email: params["email"]).to_a[0]
    if user == nil
        hashed_password = BCrypt::Password.create(params["password"])
        users_table.insert(name: params["name"], email: params["email"], password: hashed_password, phone: params["phone"] )
        view "create_user"
    else
        view "create_signup_failed"
    end
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user

        #send a text to the user who just signed in
        client.messages.create(
        from: "+17089800189", 
        to: @current_user[:phone],
        body: "Hi #{@current_user[:name]}, you just signed in to RestaurantReview. If you did not, please inform us right away at 8123908281."
)
        
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end