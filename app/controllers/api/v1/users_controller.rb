class Api::V1::UsersController < ApplicationController
  include Pagy::Backend

  PAGINATION_LIMIT = 10

  def create
    user = User.new(user_params)

    if user.save
      render json: { data: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def follow
    if followable_user.nil?
      render json: { errors: "Followable user not found" }, status: :unprocessable_content
    else
      FollowUserJob.perform_later current_user, followable_user

      render json: { message: "Follow request being processed" }, status: :accepted
    end
  end

  def unfollow
    if followable_user.nil?
      render json: { errors: "Followable user not found" }, status: :unprocessable_content
    else
      UnfollowUserJob.perform_later current_user, followable_user

      render json: { message: "Unfollow request being processed" }, status: :accepted
    end
  end

  def feeds
    cache_key = [ current_user.cache_key_with_version, :v1_user_feeds, params[:page] ]

    pagy_headers, records = Rails.cache.fetch(cache_key, expires_in: 5.minutes, race_condition_ttl: 60) do
      sleep_records = Sleep.where(user_id: current_user.following_user_ids)
                          .last_week
                          .finished
                          .sorted_by_duration

      pagy, records = pagy(sleep_records, limit: PAGINATION_LIMIT)
      [ pagy_headers(pagy), records.to_a ]
    end

    response.headers.merge!(pagy_headers)
    render json: { data: records }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:name)
  end

  def followable_user
    user_id = params[:following_id]
    User.find_by id: user_id
  end
end
