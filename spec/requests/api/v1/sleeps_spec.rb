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
