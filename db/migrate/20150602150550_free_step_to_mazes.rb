class FreeStepToMazes < ActiveRecord::Migration
  def change
    add_column :mazes, :free_step, :string
  end
end
