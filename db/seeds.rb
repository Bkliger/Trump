# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Org.destroy_all
User.destroy_all

Org.create(org_name: "General", org_status: "active")
d1 = DateTime.new(2017, 2, 26)

User.create(first: "john", last: "james", enrollment: d1)
