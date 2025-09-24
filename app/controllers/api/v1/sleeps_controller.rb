class Api::V1::SleepsController < ApplicationController
  include Pagy::Backend

  PAGINATION_LIMIT = 10

  def index
    cache_key = [ current_user.cache_key_with_version, :v1_sleep_records, params[:page] ]

    pagy_headers, records = Rails.cache.fetch(cache_key, expires_in: 5.minutes, race_condition_ttl: 60) do
      sleep_records = Sleep.where(user_id: current_user.id).order(created_at: :desc)

      pagy, records = pagy(sleep_records, limit: PAGINATION_LIMIT)
      [ pagy_headers(pagy), records.to_a ]
    end

    response.headers.merge!(pagy_headers)
    render json: { data: records }, status: :ok
  end

  def clock_in
    current_user.with_lock do
      last_sleep_record = current_user.sleeps.last
      if last_sleep_record.present? && last_sleep_record&.end.nil?
        render json: { errors: "User have active sleep record" }, status: :unprocessable_content
      else
        records = current_user.sleeps.build(start: Time.zone.now)

        if records.save
          render json: { data: records }, status: :created
        else
          render json: { errors: records.errors.full_messages }, status: :unprocessable_content
        end
      end
    end
  end

  def clock_out
    current_user.with_lock do
      last_sleep_record = current_user.sleeps.last
      if last_sleep_record.present? && last_sleep_record.end.nil?
        last_sleep_record.update!(end: Time.zone.now)
        render json: { data: last_sleep_record }, status: :ok
      else
        render json: { errors: "User does not have active sleep record" }, status: :unprocessable_content
      end
    end
  end
end
