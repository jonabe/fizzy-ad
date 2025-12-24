# API controller for board management
# Used by Factory CLI and Agent Lab for programmatic board access
#
# Authentication: Requires Bearer token (User.api_token)
# Scope: User's account only (Current.account)
#
# Example:
#   curl -H "Authorization: Bearer <token>" \
#        -H "Content-Type: application/json" \
#        -d '{"name":"My Board","description":"---\nrepo_url: https://github.com/user/repo.git\n"}' \
#        http://localhost:3006/api/boards
#
class Api::BoardsController < Api::BaseController
  before_action :set_board, only: [ :show, :update, :destroy ]

  # GET /api/boards
  def index
    boards = current_user.account.boards.alphabetically
    render json: boards.map { |board| board_json(board) }
  end

  # GET /api/boards/:id
  def show
    render json: board_json(@board)
  end

  # POST /api/boards
  def create
    board = current_user.account.boards.create!(board_params.merge(creator: current_user))
    render json: board_json(board), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH/PUT /api/boards/:id
  def update
    @board.update!(board_params)
    render json: board_json(@board)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # DELETE /api/boards/:id
  def destroy
    @board.destroy!
    head :no_content
  end

  private
    def set_board
      @board = current_user.account.boards.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Board not found" }, status: :not_found
    end

    def board_params
      params.require(:board).permit(:name, :description)
    end

    def board_json(board)
      {
        id: board.id,
        name: board.name,
        description: board.description,
        metadata: board.metadata,
        created_at: board.created_at,
        updated_at: board.updated_at
      }
    end
end
