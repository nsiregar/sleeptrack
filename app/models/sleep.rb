class Sleep < ApplicationRecord
  belongs_to :user

  validates_presence_of :start
end
