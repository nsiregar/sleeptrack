require 'rails_helper'

RSpec.describe "Api::V1::Sleeps", type: :request do
  let(:current_user) { create :user }

  describe "GET /api/v1/users/:id/sleeps" do
    let(:user_2) { create :user }
    let(:user_3) { create :user }

    before do
      current_user.follow_user(user_2)
      current_user.follow_user(user_3)

      current_user.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)
      current_user.sleeps.create!(start: 7.minutes.ago, end: 6.minutes.ago, duration: 6.minutes.ago - 7.minutes.ago)
      current_user.sleeps.create!(start: 3.minutes.ago, end: 1.minutes.ago, duration: 1.minutes.ago - 3.minutes.ago)

      user_2.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)
      user_2.sleeps.create!(start: 7.minutes.ago, end: 6.minutes.ago, duration: 6.minutes.ago - 7.minutes.ago)
      user_2.sleeps.create!(start: 3.minutes.ago, end: 1.minutes.ago, duration: 1.minutes.ago - 3.minutes.ago)

      user_3.sleeps.create!(start: 15.minutes.ago, end: 8.minutes.ago, duration: 8.minutes.ago - 15.minutes.ago)
      user_3.sleeps.create!(start: 7.minutes.ago, end: 6.minutes.ago, duration: 6.minutes.ago - 7.minutes.ago)
      user_3.sleeps.create!(start: 3.minutes.ago, end: 1.minutes.ago, duration: 1.minutes.ago - 3.minutes.ago)
    end

    it 'gets sleep records for the following users' do
      get "/api/v1/users/#{current_user.id}/sleeps"

      expect(response).to have_http_status :ok

      record_orders = response_json['data'].map { |record| [ record['user_id'], record['duration'] ] }
      expect(record_orders).to eq([
        [ 2, 419 ],
        [ 3, 419 ],
        [ 2, 119 ],
        [ 3, 119 ],
        [ 2, 59 ],
        [ 3, 59 ]
      ])
    end
  end

  describe "POST /api/v1/users/:id/sleeps/clock_in" do
    context 'when has no sleep record' do
      it 'create new sleep record' do
        post "/api/v1/users/#{current_user.id}/sleeps/clock_in"

        expect(response).to have_http_status :created
        expect(current_user.sleeps.count).to eq 1
      end
    end

    context 'when has active sleep record' do
      before { create :sleep, user: current_user, start: Time.zone.now, end: nil }

      it 'should returns errors' do
        post "/api/v1/users/#{current_user.id}/sleeps/clock_in"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to eq 'User have active sleep record'
      end
    end
  end

  describe "PATCH /api/v1/users/:id/sleeps/clock_out" do
    context 'when has no sleep record' do
      it 'returns errors' do
        patch "/api/v1/users/#{current_user.id}/sleeps/clock_out"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to eq 'User does not have active sleep record'
      end
    end

    context 'when has active sleep record' do
      before { create :sleep, user: current_user, start: Time.zone.now, end: nil }

      it 'updates active sleep record' do
        patch "/api/v1/users/#{current_user.id}/sleeps/clock_out"

        expect(response).to have_http_status :ok
        expect(current_user.sleeps.last.end).not_to be_nil
        expect(current_user.sleeps.last.duration).not_to be_nil

        expect(response_json['data']['end']).not_to be_nil
        expect(response_json['data']['duration']).not_to be_nil
      end
    end
  end
end
