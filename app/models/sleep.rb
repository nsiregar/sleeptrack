class Sleep < ApplicationRecord
  belongs_to :user

  validates_presence_of :start

  before_save :calculate_duration

  scope :last_week, -> { where(created_at: 1.week.ago..Time.now) }
  scope :finished, -> { where.not(end: nil) }
  scope :sorted_by_duration, -> { order(duration: :desc) }

  private

  def calculate_duration
    return unless self.end

    self.duration = (self.end - self.start).to_i
  end
end
