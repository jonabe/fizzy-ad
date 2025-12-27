json.cache! board do
  json.extract! board, :id, :name, :description, :all_access, :created_at, :updated_at
  json.url board_url(board)

  json.creator board.creator, partial: "users/user", as: :user
end
