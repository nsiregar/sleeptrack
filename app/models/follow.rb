class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :follower,   polymorphic: true, touch: true

  validate :follow_self

  private

  def follow_self
    if followable_id == follower_id && followable_type == follower_type
      errors.add(:base, "unable follow it self")
    end
  end
end
