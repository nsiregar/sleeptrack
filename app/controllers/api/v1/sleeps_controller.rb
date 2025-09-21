class Api::V1::SleepsController < ApplicationController
  def index
    follows_sleep_records = current_user.following_users.last_week_sleep_records

    render json: { data: follows_sleep_records }, status: :ok
  end

  def clock_in
    last_sleep_record = current_user.sleeps.last
    if last_sleep_record.present? && last_sleep_record&.end.nil?
      render json: { errors: "User have active sleep record" }, status: :unprocessable_content
    else
      record = current_user.sleeps.create(start: Time.zone.now)
      render json: { data: record }, status: :created
    end
  end

  def clock_out
    last_sleep_record = current_user.sleeps.last
    if last_sleep_record.present? && last_sleep_record.end.nil?
      current_time = Time.zone.now
      last_sleep_record.update!(end: current_time, duration: (current_time - last_sleep_record.start))

      render json: { data: last_sleep_record }, status: :ok
    else
      render json: { errors: "User does not have active sleep record" }, status: :unprocessable_content
    end
  end
end
