# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Adminuser.destroy_all
Targetmessage.destroy_all
Messhistory.destroy_all
UserOrg.destroy_all
Message.destroy_all
Org.destroy_all
Target.destroy_all
User.destroy_all




org1 = Org.create(org_name: "General", org_status: "active")
Adminuser.create(first_name: "Admin", last_name: "User", email: "test@test", org_id: org1.id)
u1 = User.create(first_name: "john", last_name: "james", enrollment: DateTime.new(2017, 2, 26), email: "john@gmail.com", password: "topsecret", password_confirmation: "topsecret")
u2 = User.create(first_name: "Bob", last_name: "Kiger", enrollment: DateTime.new(2017, 3, 26), email: "bob@gmail.com", password: "topsecret", password_confirmation: "topsecret")
UserOrg.create(user_id: u1.id, org_id: org1.id)
UserOrg.create(user_id: u2.id, org_id: org1.id)
Message.create(title: "first message", message_text: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ", create_date: DateTime.new(2017, 2, 26), org_id: org1.id)
Message.create(title: "second message", message_text: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ", create_date: DateTime.new(2017, 2, 27), org_id: org1.id)
Target.create(first: "Nettie", last: "Kliger", zip: "94702", address: "", city: "", state: "TX", salutation: "Hi Mom", email: "bkliger@comcast.net", rec_email: "1", rec_text: "1", phone: "203-234-3333", user_id: u2.id)
Target.create(first: "Billie", last: "James", zip: "77450", address: "4315 Cannondale Lane", city: "Katy", state: "TX",  salutation: "Hi Dad", email: "bkliger@comcast.net", rec_email: "1", rec_text: "0", phone: "203-234-3333", user_id: u1.id)
