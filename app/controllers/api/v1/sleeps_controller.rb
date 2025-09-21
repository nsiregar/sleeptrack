class Api::V1::SleepsController < ApplicationController
  def clock_in
    last_sleep_record = current_user.sleeps.last
    if last_sleep_record.present? && last_sleep_record&.end.nil?
      render json: { errors: "User have active sleep record" }, status: :unprocessable_content
    else
      record = current_user.sleeps.create(start: Time.zone.now)
      render json: { data: record }, status: :created
    end
  end
end
