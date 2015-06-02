class Maze < ActiveRecord::Base
  belongs_to :input_type
  has_attached_file :maze_file

  validates_attachment_size :maze_file, :less_than => 1.megabytes
  validates_attachment_presence :maze_file
  validates_attachment :maze_file, content_type: { content_type: ["text/plain", "application/text"] }

  validates_presence_of :name
  validates_presence_of :maze
  validates_presence_of :start_x
  validates_presence_of :start_y
  validates_presence_of :stop_x
  validates_presence_of :stop_y
  validates_presence_of :wall

end
