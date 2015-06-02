module BfsMaze
  # return a 2d maze matrix
  def self.read_activerecord_text(model_maze)
    return read_text(model_maze.maze)
  end

  # reads a maze. Format expected: "####   #### ####\r\n######     \r\n"
  # where #: wall
  # and ' ' a free step.
  # returns a 2d array representation of maze
  def self.read_text(text_maze)
    matrix = []
    text_maze.split("\r\n").each do |line|
      matrix << line.split(//)
    end
    matrix # 2D array [['#', '#','#', '#','#', '#'],['#', '#','S','#', '#''#', '#']]...
  end

  # read maze from file. Validation for correct format is done with active record.
  # for console application we should raise exception here too for incorrect format
  # Exception are catched in MazesController
  def self.parse_file(file)
    maze = {}
    matrix = []

      File.open(file) do |file|
        maze[:name] = file.readline.strip     # first line of file must be the name of maze
        maze[:wall] = file.readline.strip     # second line mast be the wall char
        maze[:start_x], maze[:start_y], maze[:stop_x], maze[:stop_y] = file.readline.strip.split(/,/) # next line start and stop
        file.each_line do |line|              # fill the 2d matrix
          matrix << line.gsub("\n", "\r\n").split(//)
        end
      end
      maze[:maze] = matrix.join               # store matrix on maze hash and return a maze
    maze
  end


  # Room used as linked list to trace back to its parent so we can find the path from goal to start
  class Room < Struct.new(:x, :y, :parent)
  end

  # found =  true if solved
  class Status < Struct.new(:found)
  end

  # returns the string with biggest size in an array
  class Array
    def longest_word
      group_by(&:size).max.last.first.size
    end
  end

  # solver
  class BFSSolver
    attr_accessor :maze         # hash to hold maze info: matrix start, stop and wall char
    attr_accessor :status

    # initialize maze
    def initialize(matrix, maze)
      @maze = {}
      @maze[:matrix] = matrix
      @maze[:start_x] = maze.start_x
      @maze[:start_y] = maze.start_y
      @maze[:stop_x] = maze.stop_x
      @maze[:stop_y] = maze.stop_y
      @maze[:wall] = maze.wall

      @status = Status.new(false)       # status false: path not found
      @maze[:path] = Room.new(nil, nil, nil) # Stack Get the path found from Goal to Start
    end

    # check if start and stop is not a wall. Validation is also performed in activerecord model (Maze.rb in models)
    def check_for_error
      start_x = @maze[:start_x]
      start_y = @maze[:start_y]
      stop_x = @maze[:stop_x]
      stop_y = @maze[:stop_y]
      if @maze[:matrix][start_y][start_x] == @maze[:wall] || @maze[:matrix][stop_y][stop_x] == @maze[:wall]
        raise "Start or Goal cannot be a wall!!!"
      end
    end

    # prints the maze to console
    def print
      @maze[:matrix].each do |line|
        puts line.join
      end
    end

    # yild each line
    def print_each_line
      @maze[:matrix].each do |line|
        yield line.join
      end
    end

    # bfs algorithm to solve the maze
    def solve_maze
      matrix = @maze[:matrix]       # get matrix from maze hash
      exit_found = false            # exit not found yet
      room = Room.new(@maze[:start_x], @maze[:start_y], nil)  # create new room from start position
      queue = Queue.new           # queue to store the current working nodes' children
      queue << room               # add the new room to queue

      # if path not found and queue not empty
      while !queue.empty? && !exit_found
        room = queue.pop        # get the next room to search for a path
        x = room.x
        y = room.y
        if (x == @maze[:stop_x] && y == @maze[:stop_y])     # if found
          exit_found = true
        else                                                # if not found
          matrix[y][x] = '*'                                # Mark node as visited sto we do not check it again (bfs algorithm)

          # push to queue the children of node room. We are pushing the up, down, left or right room if they are not a wall and we
          # we haven't visited them yet
          queue << Room.new(x+1,y,room) if open_room(x+1,y,matrix) and !visited(x+1, y, matrix)
          queue << Room.new(x-1,y,room) if open_room(x-1,y,matrix) and !visited(x-1,y,matrix)
          queue << Room.new(x,y+1,room) if open_room(x,y+1,matrix) and !visited(x, y+1, matrix)
          queue << Room.new(x,y-1,room) if open_room(x,y-1,matrix) and !visited(x, y-1, matrix)
        end
      end

      # if goal found store the last room to @maze[:path]. The last room has a reference(:parent) to the previous room. So we can trace the path
      if exit_found
        @status.found = true
        @maze[:path] = room
      else
        @status.found = false
      end

      # yields x, y coordinates of path starting from goal to start
      def yield_path
        room = @maze[:path]
        while room.parent
          yield room.x, room.y
          room = room.parent
        end
      end

      # get an array of path
      def path_array
        path = []
        yield_path do |x, y|
          path << [x,y]
        end
      path.reverse
      end
    end

    private
    # check if room is open (not a wall and not out of mazes dimensions)
    def open_room(x,y,matrix)
      return false if (x < 0 || x > matrix.max.size - 1 || y < 0 || y > matrix.size-1)
      return matrix[y][x] != @maze[:wall]
    end

    # check if node has been visited
    def visited(x, y, matrix)
      if open_room(x,y, matrix)
        return matrix[y][x] == '*'
      end
    end
  end
end