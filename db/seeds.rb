# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(name:  "zino sama",
             email: "test@gmail.com",
             password:              "dasdaa",
             password_confirmation: "dasdaa",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@gmail.com"
  password = "dasdaa"
  phone = "5478-9347"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               phone: phone,
               activated: true,
               activated_at: Time.zone.now)
end