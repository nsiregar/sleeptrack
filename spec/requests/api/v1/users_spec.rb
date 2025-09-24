require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    context 'when use valid params' do
      it 'should create new user' do
        post '/api/v1/users', params: { user: { name: 'test_user' } }

        expect(User.count).to eq 1
        expect(User.first.name).to eq 'test_user'

        expect(response_json['data']['name']).to eq 'test_user'
      end
    end

    context 'when use invalid params' do
      it 'should not create new user' do
        post '/api/v1/users', params: { user: { name: '' } }

        expect(User.count).to eq 0

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to include "Name can't be blank"
      end
    end
  end


  describe "POST /api/v1/users/:id/follow/:following_id" do
    let(:user_1) { create :user }
    let(:user_2) { create :user }

    context 'followable user exists' do
      it 'process follow request' do
        post "/api/v1/users/#{user_1.id}/follow/#{user_2.id}"

        expect(response).to have_http_status :accepted
        assert_enqueued_jobs 1, only: FollowUserJob
      end
    end

    context 'when user follow non exists user' do
      it 'returns errors' do
        post "/api/v1/users/#{user_1.id}/follow/100"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to include "Followable user not found"
      end
    end
  end

  describe "DELETE /api/v1/users/:id/follow/:following_id" do
    let(:user_1) { create :user }
    let(:user_2) { create :user }

    context 'when user already follow' do
      it 'should remove follow relationship' do
        user_1.follow_user(user_2)

        delete "/api/v1/users/#{user_1.id}/follow/#{user_2.id}"

        expect(response).to have_http_status :accepted
        assert_enqueued_jobs 1, only: UnfollowUserJob
      end
    end

    context 'when user unfollow non exists user' do
      it 'returns errors' do
        delete "/api/v1/users/#{user_1.id}/follow/100"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to include "Followable user not found"
      end
    end
  end

  describe "GET /api/v1/users/:id/feeds" do
    let(:current_user) { create :user }
    let(:user_2) { create :user }
    let(:user_3) { create :user }
    let(:user_4) { create :user }

    before do
      current_user.follow_user(user_2)
      current_user.follow_user(user_3)

      current_user.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)
      user_4.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)

      user_2.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)
      user_2.sleeps.create!(start: 7.minutes.ago, end: 6.minutes.ago, duration: 6.minutes.ago - 7.minutes.ago)
      user_2.sleeps.create!(start: 3.minutes.ago, end: 1.minutes.ago, duration: 1.minutes.ago - 3.minutes.ago)

      user_3.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)
      user_3.sleeps.create!(start: 7.minutes.ago, end: 6.minutes.ago, duration: 6.minutes.ago - 7.minutes.ago)
      user_3.sleeps.create!(start: 3.minutes.ago, end: 1.minutes.ago, duration: 1.minutes.ago - 3.minutes.ago)

      stub_const('Api::V1::UsersController::PAGINATION_LIMIT', 3)
    end

    it 'gets sleep records for the following users with pagination' do
      get "/api/v1/users/#{current_user.id}/feeds"

      expect(response).to have_http_status :ok

      first_record_orders = response_json['data'].map { |record| [ record['user_id'], record['duration'] ] }
      expect(first_record_orders).to eq([
        [ user_2.id, 420 ],
        [ user_3.id, 420 ],
        [ user_2.id, 120 ]
      ])

      get "/api/v1/users/#{current_user.id}/feeds?page=2"

      expect(response).to have_http_status :ok

      second_record_orders = response_json['data'].map { |record| [ record['user_id'], record['duration'] ] }
      expect(second_record_orders).to eq([
        [ user_3.id, 120 ],
        [ user_2.id, 60 ],
        [ user_3.id, 60 ]
      ])
    end
  end
end
