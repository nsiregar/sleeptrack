class FollowUserJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordInvalid
  discard_on ActiveRecord::RecordNotUnique

  def perform(user, followable_user)
    user.follow_user(followable_user)
  end
end
