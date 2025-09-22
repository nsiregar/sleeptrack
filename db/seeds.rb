# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Create the main user for our benchmark
main_user = User.find_or_create_by!(id: 1) do |u|
  u.name = "Benchmark User"
end

puts "Created main user."

# Create 10 followed users
followed_users = 10.times.map do |i|
  User.find_or_create_by!(name: "Followed User #{i + 1}")
end

puts "Created 10 followed users."

# Make the main user follow them
followed_users.each do |followed_user|
  # Use find_or_create_by to make the seed idempotent
  main_user.follow_user(followed_user)
end

puts "Main user is now following 10 users."

# Create 2 weeks of sleep data for each followed user
followed_users.each do |followed_user|
  14.times do |i|
    # Check if a sleep record for this user and day already exists
    unless followed_user.sleeps.where(created_at: (i.days.ago.beginning_of_day)..(i.days.ago.end_of_day)).exists?
      followed_user.sleeps.create!(
        start: i.days.ago,
        created_at: i.days.ago,
        end: i.days.ago + (rand(6..10)).hours, # Random sleep duration
        duration: rand(21600..36000)
      )
    end
  end
end

puts "Created 2 weeks of sleep data for each followed user."
puts "Seeding complete."
