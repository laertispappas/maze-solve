class Removefreestep < ActiveRecord::Migration
  def change
    remove_column :mazes, :free_step
  end
end
