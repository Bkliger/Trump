# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Message.destroy_all
Org.destroy_all
Target.destroy_all
User.destroy_all


org1 = Org.create(org_name: "General", org_status: "active")
u1 = User.create(first: "john", last: "james", enrollment: DateTime.new(2017, 2, 26))
u2 = User.create(first: "Bob", last: "Kiger", enrollment: DateTime.new(2017, 3, 26))
Message.create(title: "first message", message_text: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ", create_date: DateTime.new(2017, 2, 26), org_id: org1.id)
Message.create(title: "second message", message_text: "lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum ", create_date: DateTime.new(2017, 2, 27), org_id: org1.id)
Target.create(first: "Nettie", last: "Kliger", zip: "94702", plus4: "5305", salutation: "Hi Mom", email: "nettie@comcast.net", rec_email: "1", rec_text: "1", phone: "203-234-3333", user_id: u2.id)
Target.create(first: "Billie", last: "James", zip: "94702", plus4: "5305", salutation: "Hi Dad", email: "nettie@comcast.net", rec_email: "1", rec_text: "0", phone: "203-234-3333", user_id: u1.id)
