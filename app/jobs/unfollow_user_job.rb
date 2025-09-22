class UnfollowUserJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::ActiveRecordError

  def perform(user, followable_user)
    user.unfollow_user(followable_user)
  end
end
