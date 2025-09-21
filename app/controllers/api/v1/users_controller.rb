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
      record = current_user.follow_user(followable_user)

      render json: { data: record }, status: :created
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: "User already follow #{followable_user.id}" }, status: :unprocessable_content
  rescue ActiveRecord::RecordInvalid
    render json: { errors: "User can not follow it self" }, status: :unprocessable_content
  end

  def unfollow
    if followable_user.nil?
      render json: { errors: "Followable user not found" }, status: :unprocessable_content
    else
      record = current_user.unfollow_user(followable_user)

      render json: { data: record }, status: :ok
    end
  rescue ActiveRecord::ActiveRecordError
    render json: { errors: "User is not following followable" }, status: :unprocessable_content
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
