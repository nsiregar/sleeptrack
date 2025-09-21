class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.references :followable, polymorphic: true, null: false
      t.references :follower,   polymorphic: true, null: false

      t.timestamps
    end

    add_index :follows, [ "follower_id", "follower_type" ],     name: "fk_follows"
    add_index :follows, [ "followable_id", "followable_type" ], name: "fk_followables", unique: true
  end
end
