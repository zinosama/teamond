# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(name:  "shopper zino",
             email: "test@gmail.com",
             password:              "dasdaa",
             password_confirmation: "dasdaa",
             activated: true,
             activated_at: Time.zone.now
             )
root_admin = User.new(name: "admin zino",
						 email: "admin@gmail.com",
						 password: "dasdaa",
						 password_confirmation: "dasdaa",
						 activated: true,
						 activated_at: Time.zone.now
						)
root_admin.role = Admin.create(user: root_admin)
root_admin.save!

# 99.times do |n|
#   name  = Faker::Name.name
#   email = "example-#{n+1}@gmail.com"
#   password = "dasdaa"
#   phone = "5478-9347"
#   User.create!(name:  name,
#                email: email,
#                password:              password,
#                password_confirmation: password,
#                phone: phone,
#                activated: true,
#                activated_at: Time.zone.now)
# end

store_one = Store.create!(name: "Asian Cafe", phone: "2341232", owner: "Harry Porter", address: "500 Joseph C Wilson Blvd", active: true)

Milktea.create!(name: "uuulong milktea", description:"first milktea", store: store_one, price: 1.23, image: File.open(File.join(Rails.root, '/test/fixtures/images/tea.jpg')))
MilkteaAddon.create!(name: "bubble", price: 0.5)
MilkteaAddon.create!(name: "red bean", price: 0.5)
MilkteaAddon.create!(name: "green bean", price: 0.5)

DishCategory.create!(name: "Fried Rice")

PickupLocation.create!(name: "Wilson Commons", address: "500 joseph c wilson blvd", description: "Meet us at the front door!")
PickupLocation.create!(name: "ITS", address: "500 jospeph c wilson blvd - IT center", description: "We are on the first floor.")
PickupTime.create!(pickup_hour: 18, pickup_minute: 20, cutoff_hour: 17, cutoff_minute: 15)
PickupTime.create!(pickup_hour: 17, pickup_minute: 0, cutoff_hour: 16, cutoff_minute: 0)
PickupTime.create!(pickup_hour: 20, pickup_minute: 30, cutoff_hour: 19, cutoff_minute: 0)
