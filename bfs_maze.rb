module BfsMaze
  # Example:
  # require './maze'
  # maze = Maze.load('./mymaze.txt')
  # maze_solver = Maze::Solver.new(maze)
  # maze_solver.solve

  # read from file and return a 2d matrix

  def self.read_activerecord_text(model_maze)
    return read_text(model_maze.maze)
  end

  def self.read_text(text_maze)
    matrix = []
    text_maze.each_line do |line|
      matrix << line.chomp.split(//)
    end
    matrix # 2D array [['#', '#','#', '#','#', '#'],['#', '#','S','#', '#''#', '#']]...
  end

  def self.parse_file(file)
    maze = {}
    matrix = []

    File.open(file) do |file|
      maze[:name] = file.readline
      maze[:wall] = file.readline
      maze[:start_x], maze[:start_y], maze[:stop_x], maze[:stop_y] = file.readline.split(/,/)
      file.each_line do |line|
        matrix << line.split(//)
      end
    end
    maze[:maze] = matrix.join.gsub(/,/, "")
    maze
  end


  # Room to hold an x,y square during maze traversal, with
  # a link back to it's parent.  Links are used after the exit
  # is found to trace exit back to entrance.
  class Room < Struct.new(:x, :y, :parent)
  end

  # true if solved
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

      @show_progress = false
      @status = Status.new(false)
      @maze[:path] = Room.new(nil, nil, nil)              # Stack Get the path found from Goad room to Start room
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
          print if @show_progress
          queue << Room.new(x+1,y,room) if open_room(x+1,y,matrix)
          queue << Room.new(x-1,y,room) if open_room(x-1,y,matrix)
          queue << Room.new(x,y+1,room) if open_room(x,y+1,matrix)
          queue << Room.new(x,y-1,room) if open_room(x,y-1,matrix)
        end
      end

      # Clear all pathway markers and keep only whitespaces
      clear_matrix
      if exit_found
        @status.found = true
        @maze[:path] = room
        # Repaint solution pathway with markers

#        matrix[room.y][room.x] = '>'
        while room.parent
          room = room.parent
          matrix[room.y][room.x] = '-'
        end
        puts "Maze solved:\n\n"
        print
      else
        puts 'No exit found'
        @status.found = false
      end

      def yield_path
        room = @maze[:path]
        while room.parent
          yield room.x, room.y
          room = room.parent
        end
      end

    end

    private
    def open_room(x,y,matrix)
      return false if (x<0 || x>matrix[0].size-1 || y<0 || y>matrix.size-1)
      return matrix[y][x] == ' '
    end

    def clear_matrix
      @maze[:matrix].each_index do |idx|
        @maze[:matrix][idx] = @maze[:matrix][idx].join.gsub(/[^#|\s]/i,' ').split(//)
#        puts @maze[:matrix][idx]
      end
    end
  end
end