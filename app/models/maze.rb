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
  validate :accept_one_char_for_wall
  validate :do_not_accept_asterisk
  validate :do_not_accept_asterisk_in_maze
  validate :start_stop_in_maze
  validate :start_stop_not_a_wall

  default_scope { order("created_at DESC") }


  def max_width
    self.maze.split("\r\n").max.size
  end

  def max_height
    self.maze.split("\r\n").size
  end

  def accept_one_char_for_wall
    if self.wall.size > 1
      errors.add(:wall, "Must be one character")
    end
  end

  def do_not_accept_asterisk
    if self.wall == "*"
      errors.add(:wall, "Cannot be an asterisk")
    end
  end

  def do_not_accept_asterisk_in_maze
    if self.maze.include?("*")
      errors.add(:maze, "Cannot contain an asterisk")
    end
  end

  def start_stop_not_a_wall
    m = self.maze
    matrix = []
    m.split("\r\n").each do |line|
      matrix << line.split(//)
    end
    if matrix[self.start_y][self.start_x] == self.wall || matrix[self.stop_y][self.stop_x] == self.wall
      errors.add("Start or stop position is a wall", "")
    end
  end

  def start_stop_in_maze
    width = self.max_width
    height = self.max_height
    if !self.start_x.in?(0..width) || !self.stop_x.in?(0..height) || !self.stop_x.in?(0..width) || !self.stop_y.in?(0..height)
      errors.add("Start or stop position",  "is not in maze")
    end
  end
end
