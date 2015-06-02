json.array!(@mazes) do |maze|
  json.extract! maze, :id, :name, :maze, :start_x, :start_y, :stop_x, :stop_y, :wall
  json.url maze_url(maze, format: :json)
end
