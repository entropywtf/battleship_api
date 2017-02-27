class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.integer :winner_uid
      t.integer :turn_uid
      t.string :state

      t.timestamps
    end
  end
end
