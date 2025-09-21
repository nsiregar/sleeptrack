class User < ApplicationRecord
  has_many :sleeps

  has_many :followings, as: :followable, dependent: :destroy, class_name: "Follow"
  has_many :followers, through: :followings, source: :follower, source_type: "User"

  has_many :follows, as: :follower, dependent: :destroy
  has_many :following_users, through: :follows, source: :followable, source_type: "User"

  validates_presence_of :name
  validates_uniqueness_of :name
end
