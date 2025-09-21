class CreateSleeps < ActiveRecord::Migration[8.0]
  def change
    create_table :sleeps do |t|
      t.belongs_to :user
      t.datetime :start
      t.datetime :end
      t.integer :duration

      t.timestamps
    end
  end
end
