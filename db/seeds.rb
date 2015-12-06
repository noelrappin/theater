# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "active_record/fixtures"

user = CreateAdminService.new.call
puts "CREATED ADMIN USER: " << user.email # rubocop:disable Rails/Output
# Environment variables (ENV['...']) can be set in the file .env file.

ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/spec/fixtures", "events")
ActiveRecord::Fixtures.create_fixtures(
  "#{Rails.root}/spec/fixtures", "performances")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/spec/fixtures", "tickets")
ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/spec/fixtures", "users")
