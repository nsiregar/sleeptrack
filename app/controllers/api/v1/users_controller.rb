class Api::V1::UsersController < ApplicationController
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

  private

  def user_params
    params.require(:user).permit(:name)
  end

  def followable_user
    user_id = params[:following_id]
    User.find_by id: user_id
  end
end
