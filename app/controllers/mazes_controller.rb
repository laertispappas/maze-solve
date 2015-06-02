class MazesController < ApplicationController
  before_action :set_maze, only: [:show, :edit, :update, :destroy, :solve]
  def solve
    @matrix = BfsMaze.read_text(@maze.maze)
    @maze_solver = BfsMaze::BFSSolver.new(@matrix, @maze)
#    @maze_solver.check_for_error
    @maze_solver.solve_maze
    @path = @maze_solver.path_array
#rescue
#    flash[:alert] = "Start or Goal cannot be a wall or outside maze!!!"
#    redirect_to mazes_url
  end

  # GET /mazes
  # GET /mazes.json
  def index
    @mazes = Maze.all
  end

  # GET /mazes/1
  # GET /mazes/1.json
  def show
  end

  # GET /mazes/new
  def new
    @maze = Maze.new
  end

  # GET /mazes/1/edit
  def edit
  end

  # POST /mazes
  # POST /mazes.json
  def create
    if params[:maze][:maze_file].present?
      file = params[:maze][:maze_file]
      maze_hash = BfsMaze.parse_file(file.path)
      respond_to do |format|
        @maze = Maze.new(maze_hash)
        if @maze.save(maze_hash)
          format.html { redirect_to @maze, notice: 'Maze was successfully uploaded.' }
          format.json { render :show, status: :ok, location: @maze }
        else
          format.html { render :new }
          format.json { render json: @maze.errors, status: :unprocessable_entity }
        end
      end
    else
      @maze = Maze.new(maze_params)
      respond_to do |format|
        if @maze.save
          format.html { redirect_to @maze, notice: 'Maze was successfully created.' }
          format.json { render :show, status: :ok, location: @maze }
        else
          format.html { render :edit }
          format.json { render json: @maze.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /mazes/1
  # PATCH/PUT /mazes/1.json
  def update
    if params[:maze][:maze_file].present?
      file = params[:maze][:maze_file]
      maze_hash = BfsMaze.parse_file(file.path)
      p maze_hash
      respond_to do |format|
        if @maze.update(maze_hash)
          format.html { redirect_to @maze, notice: 'Maze was successfully updated.' }
          format.json { render :show, status: :ok, location: @maze }
        else
          format.html { render :edit }
          format.json { render json: @maze.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @maze.update(maze_params)
          format.html { redirect_to @maze, notice: 'Maze was successfully updated.' }
          format.json { render :show, status: :ok, location: @maze }
        else
          format.html { render :edit }
          format.json { render json: @maze.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /mazes/1
  # DELETE /mazes/1.json
  def destroy
    @maze.destroy
    respond_to do |format|
      format.html { redirect_to mazes_url, notice: 'Maze was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maze
      @maze = Maze.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def maze_params
      params.require(:maze).permit(:name, :maze, :start_x, :start_y, :stop_x, :stop_y, :wall, :free_step, :maze_file)
    end

end
