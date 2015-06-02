module BfsMaze

  # read from file and return a 2d matrix
  def self.read_activerecord_text(model_maze)
    return read_text(model_maze.maze)
  end

  def self.read_text(text_maze)
    matrix = []
    text_maze.split("\r\n").each do |line|
      matrix << line.split(//)
    end
    matrix # 2D array [['#', '#','#', '#','#', '#'],['#', '#','S','#', '#''#', '#']]...
  end

  def self.parse_file(file)
    maze = {}
    matrix = []

      File.open(file) do |file|
        maze[:name] = file.readline.strip
        maze[:wall] = file.readline.strip
        maze[:start_x], maze[:start_y], maze[:stop_x], maze[:stop_y] = file.readline.strip.split(/,/)
        file.each_line do |line|
          matrix << line.gsub("\n", "\r\n").split(//)
        end
      end
      maze[:maze] = matrix.join
    maze
  end


  # Room to hold x,y during maze traversal, with
  # a link back to it's parent. Used as linked list to trace back to its parent so we can find the path from goal to start
  class Room < Struct.new(:x, :y, :parent)
  end

  # found =  true if solved
  class Status < Struct.new(:found)
  end

  class BFSSolver
    attr_accessor :maze
    attr_reader :show_progress
    attr_accessor :status

    def initialize(matrix, maze)
      @maze = {}
      @maze[:matrix] = matrix
      @maze[:start_x] = maze.start_x
      @maze[:start_y] = maze.start_y
      @maze[:stop_x] = maze.stop_x
      @maze[:stop_y] = maze.stop_y
      @maze[:wall] = maze.wall

      @status = Status.new(false)
      @maze[:path] = Room.new(nil, nil, nil) # Stack Get the path found from Goal to Start
    end

    def check_for_error
      start_x = @maze[:start_x]
      start_y = @maze[:start_y]
      stop_x = @maze[:stop_x]
      stop_y = @maze[:stop_y]
      if @maze[:matrix][start_y][start_x] == @maze[:wall] || @maze[:matrix][stop_y][stop_x] == @maze[:wall]
        raise "Start or Goal cannot be a wall!!!"
      end
    end

    def print
      @maze[:matrix].each do |line|
        puts line.join
      end
    end

    def print_each_line
      @maze[:matrix].each do |line|
        yield line.join
      end
    end

    def solve_maze
      matrix = @maze[:matrix]
      exit_found = false
      room = Room.new(@maze[:start_x], @maze[:start_y], nil)
      queue = Queue.new
      queue << room

      while !queue.empty? && !exit_found
        room = queue.pop
        x = room.x
        y = room.y
        if (x == @maze[:stop_x] && y == @maze[:stop_y])
          exit_found = true
        else
          matrix[y][x] = '*'  # Mark path as visited

          queue << Room.new(x+1,y,room) if open_room(x+1,y,matrix) and !visited(x+1, y, matrix)
          queue << Room.new(x-1,y,room) if open_room(x-1,y,matrix) and !visited(x-1,y,matrix)
          queue << Room.new(x,y+1,room) if open_room(x,y+1,matrix) and !visited(x, y+1, matrix)
          queue << Room.new(x,y-1,room) if open_room(x,y-1,matrix) and !visited(x, y-1, matrix)
        end
      end

      if exit_found
        @status.found = true
        @maze[:path] = room
      else
        @status.found = false
      end

      def yield_path
        room = @maze[:path]
        while room.parent
          yield room.x, room.y
          room = room.parent
        end
      end

      def path_array
        path = []
        yield_path do |x, y|
          path << [x,y]
        end
      path.reverse
      end
    end

    private
    def open_room(x,y,matrix)
      return false if (x < 0 || x > matrix.max.size - 1 || y < 0 || y > matrix.size-1)
      return matrix[y][x] != @maze[:wall]
    end

    def visited(x, y, matrix)
      if open_room(x,y, matrix)
        return matrix[y][x] == '*'
      end
    end
  end
end