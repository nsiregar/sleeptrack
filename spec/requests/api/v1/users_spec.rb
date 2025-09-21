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

    context 'when user never follow' do
      it 'should creates new relation follow' do
        post "/api/v1/users/#{user_1.id}/follow/#{user_2.id}"

        expect(response).to have_http_status :created

        expect(user_1.following_users.first).to eq user_2
        expect(user_2.followers.first).to eq user_1
      end
    end

    context 'when user already follow' do
      it 'returns errors' do
        user_1.follow_user(user_2)

        post "/api/v1/users/#{user_1.id}/follow/#{user_2.id}"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to include "User already follow #{user_2.id}"
      end
    end

    context 'when user follow it self' do
      it 'returns errors' do
        post "/api/v1/users/#{user_1.id}/follow/#{user_1.id}"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to include "User can not follow it self"
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

    context 'when user never follow' do
      it 'returns errors' do
        delete "/api/v1/users/#{user_1.id}/follow/#{user_2.id}"

        expect(response).to have_http_status :unprocessable_content
        expect(response_json['errors']).to include "User is not following followable"
      end
    end

    context 'when user already follow' do
      it 'should remove follow relationship' do
        user_1.follow_user(user_2)

        delete "/api/v1/users/#{user_1.id}/follow/#{user_2.id}"

        expect(response).to have_http_status :ok
        expect(user_1.following_users.first).to be_nil
        expect(user_2.followers.first).to be_nil
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
