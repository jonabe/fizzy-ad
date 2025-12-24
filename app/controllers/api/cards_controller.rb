# API controller for card management
# Used by Factory CLI and Agent Lab for programmatic card access
#
# Authentication: Requires Bearer token (User.api_token)
# Scope: User's account only (Current.account)
#
# Example:
#   curl -H "Authorization: Bearer <token>" \
#        -H "Content-Type: application/json" \
#        -d '{"board_id":"<board_id>","title":"Fix bug","description":"Details here"}' \
#        http://localhost:3006/api/cards
#
class Api::CardsController < Api::BaseController
  before_action :set_card, only: [ :show, :update, :destroy ]
  before_action :set_board, only: [ :create ]

  # GET /api/cards
  # GET /api/cards?board_id=<id>
  def index
    cards = current_user.account.cards.latest
    cards = cards.where(board_id: params[:board_id]) if params[:board_id].present?
    render json: cards.map { |card| card_json(card) }
  end

  # GET /api/cards/:id
  def show
    render json: card_json(@card)
  end

  # POST /api/cards
  def create
    card = @board.cards.create!(card_params.merge(creator: current_user))
    render json: card_json(card), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # PATCH/PUT /api/cards/:id
  def update
    @card.update!(card_params)
    render json: card_json(@card)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # DELETE /api/cards/:id
  def destroy
    @card.destroy!
    head :no_content
  end

  # POST /api/cards/:id/move
  def move
    @card = current_user.account.cards.find(params[:id])
    column = current_user.account.columns.find(params[:column_id])
    @card.update!(column: column)
    render json: card_json(@card)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Card or column not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    def set_card
      @card = current_user.account.cards.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Card not found" }, status: :not_found
    end

    def set_board
      @board = current_user.account.boards.find(params[:board_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Board not found" }, status: :not_found
    end

    def card_params
      params.require(:card).permit(:title, :description, :column_id, :board_id)
    end

    def card_json(card)
      {
        id: card.id,
        board_id: card.board_id,
        column_id: card.column_id,
        title: card.title,
        description: card.description.to_s,
        number: card.number,
        created_at: card.created_at,
        updated_at: card.updated_at
      }
    end
end
