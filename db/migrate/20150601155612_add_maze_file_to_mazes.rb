class AddMazeFileToMazes < ActiveRecord::Migration
  def up
    add_attachment :mazes, :maze_file
  end

  def down
    remove_attachment :mazes, :maze_file
  end
end
