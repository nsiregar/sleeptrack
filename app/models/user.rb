class User < ApplicationRecord
  has_many :sleeps

  validates_presence_of :name
  validates_uniqueness_of :name
end
