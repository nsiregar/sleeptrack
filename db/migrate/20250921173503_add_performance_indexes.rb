class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    remove_index :follows, name: "fk_followables"
    add_index :follows, [ :follower_id, :follower_type, :followable_id, :followable_type ], unique: true, name: "index_follows_on_follower_and_followable"

    add_index :sleeps, :created_at
    add_index :sleeps, :duration
  end
end
