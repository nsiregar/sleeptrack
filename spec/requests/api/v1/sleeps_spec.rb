require 'rails_helper'

RSpec.describe "Api::V1::Sleeps", type: :request do
  let(:current_user) { create :user }

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
end
