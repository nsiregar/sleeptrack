require "rails_helper"
require "benchmark/ips"

RSpec.describe "Performance", type: :request do
  let!(:user) { create(:user) }
  let!(:followed_users) { create_list(:user, 10) }

  before do
    # Create a large amount of test data
    followed_users.each do |followed_user|
      user.follow_user(followed_user)
      # Create sleep records for the last 2 weeks
      14.times do |i|
        create(:sleep, user: followed_user, created_at: i.days.ago, start: i.days.ago, end: i.days.ago + 8.hours, duration: 8 * 3600)
      end
    end

    # create user sleep records
    10_000.times do |i|
      create(:sleep, user: user, created_at: i.days.ago, start: i.days.ago, end: i.days.ago + 8.hours, duration: 8 * 3600)
    end
  end

  describe "GET /api/v1/users/:id/sleeps" do
    it "benchmarks fetching sleep records" do
      Benchmark.ips do |x|
        x.report("get sleep records") do
          get "/api/v1/users/#{user.id}/sleeps"
        end

        x.compare!
      end
    end
  end

  describe "GET /api/v1/users/:id/feeds" do
    it "benchmarks fetching sleep records of followed users" do
      Benchmark.ips do |x|
        x.report("get friend's sleep feeds") do
          get "/api/v1/users/#{user.id}/feeds"
        end

        x.compare!
      end
    end
  end

  describe "DELETE /api/v1/users/:id/follow/:following_id" do
    it "benchmarks the lookup for the unfollow action" do
      Benchmark.ips do |x|
        x.report("unfollow user") do
          sample_user = followed_users.sample
          delete "/api/v1/users/#{user.id}/follow/#{sample_user.id}"
        end

        x.compare!
      end
    end
  end

  describe "POST /api/v1/users/:id/sleeps/clock_in" do
    it "benchmark clock in cation" do
      Benchmark.ips do |x|
        x.report("clock_in") do
          post "/api/v1/users/#{user.id}/sleeps/clock_in"
          user.sleeps.last.update!(end: Time.zone.now)
        end

        x.compare!
      end
    end
  end
end
