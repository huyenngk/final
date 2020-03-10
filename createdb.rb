# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :restaurants do
  primary_key :id
  String :name
  String :description, text: true
  String :popular_dishes, text: true
  String :location
  String :phone
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :restaurant_id
  foreign_key :user_id
  Boolean :enjoying
  String :reviews, text: true
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
  String :phone
end

# Insert initial (seed) data
restaurants_table = DB.from(:restaurants)

restaurants_table.insert(name: "Nha Hang Viet Nam", 
                    description: "We have specialties: Bun mam #83, Bun Cha Ca #89, Ca Thit Kho To #158, Canh chua ca #149, and other hot pots .....and more BYOB",
                    popular_dishes: "Spring Rolls, Bun Bo Hue, Banh Xeo",
                    location: "1032 W Argyle St Chicago, IL 60640",
                    phone:"(773) 878-8895")

restaurants_table.insert(name: "Hong Ngu", 
                    description: "Simplicity, authenticity and a taste you won't easily forget.",
                    popular_dishes: "Vietnamese Stone Bowl Pho, Spring Roll, Papaya Salad",
                    location: "1113 W Argyle St Chicago, IL 60640",
                    phone:"(773) 595-8888")

restaurants_table.insert(name: "Lotus Cafe", 
                    description: "Well-known Vietnamese sandwich specialist with a cozy ambiance, outdoor seating & fruit smoothies.",
                    popular_dishes: "Honey Grilled Pork, Beef and Mushroom Banh Mi, Ginger Chicken",
                    location: "719 W Maxwell St Chicago, IL 60607",
                    phone:"(312) 733-7595")

restaurants_table.insert(name: "Uptown Pho", 
                    description: "Dine in, carry out, catering and delivery",
                    popular_dishes: "Bun Bo Hue, Crab Ragoon, Pho Tai",
                    location: "1010 W Argyle St Chicago, IL 60640",
                    phone:"(773) 878-8820")

restaurants_table.insert(name: "DaNang Kitchen", 
                    description: "Come and check out our new restaurant in Chicago uptown! Call in or stop by for some
vietnamese food! We are also BYOB!",
                    popular_dishes: "Mi Quang, Banh Khot, Com Tam Suon Cha",
                    location: "1019 W Argyle St Chicago, IL 60640",
                    phone:"(773) 654-3564")


