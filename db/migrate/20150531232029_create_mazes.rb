class CreateMazes < ActiveRecord::Migration
  def change
    create_table :mazes do |t|
      t.string :name
      t.text :maze
      t.integer :start_x
      t.integer :start_y
      t.integer :stop_x
      t.integer :stop_y
      t.string :wall
      t.string :free_step

      t.timestamps null: false
    end
  end
end
