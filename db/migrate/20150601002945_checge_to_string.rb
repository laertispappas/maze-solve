class ChecgeToString < ActiveRecord::Migration
  def change
    remove_column :mazes, :maze
    add_column :mazes, :maze, :string
  end
end
