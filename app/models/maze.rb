class Maze < ActiveRecord::Base
  belongs_to :input_type
  has_attached_file :maze_file

  validates_attachment_size :maze_file, :less_than => 1.megabytes
  validates_attachment :maze_file, content_type: { content_type: ["text/plain", "application/text"] }

  validates_presence_of :name
  validates_presence_of :maze
  validates_presence_of :start_x
  validates_presence_of :start_y
  validates_presence_of :stop_x
  validates_presence_of :stop_y
  validates_presence_of :wall

  default_scope { order("created_at DESC") }


  def max_width
    self.maze.split("\r\n").max.size
  end

  def max_height
    self.maze.split("\r\n").size
  end

end
