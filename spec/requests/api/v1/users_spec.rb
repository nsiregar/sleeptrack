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
end
