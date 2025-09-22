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
end
