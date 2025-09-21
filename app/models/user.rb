class User < ApplicationRecord
  has_many :sleeps

  has_many :followings, as: :followable, dependent: :destroy, class_name: "Follow"
  has_many :followers, through: :followings, source: :follower, source_type: "User"

  has_many :follows, as: :follower, dependent: :destroy
  has_many :following_users, through: :follows, source: :followable, source_type: "User"

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :last_week_sleep_records, lambda {
    joins(sleeps: :user)
      .where(sleeps: { created_at: 1.week.ago..Time.now })
      .where.not(sleeps: { end: nil })
      .order(duration: :desc)
      .select("sleeps.*")
      .distinct
  }

  def follow_user(user)
    follows.create!(followable_id: user.id, followable_type: user.class.name)
  end

  def unfollow_user(user)
    following_state = follows.find_by(followable_id: user.id, followable_type: user.class.name)

    raise ActiveRecord::ActiveRecordError unless following_state.present?

    following_state.destroy
  end
end
