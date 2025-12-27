module Factory
  class CardsController < ApplicationController
    def create
      account = Current.account || Account.first
      Current.account ||= account if account

      board = Board.find(params[:board_id])
      card = board.cards.new(card_params)
      card.creator = account.system_user

      if card.save
        render json: card, status: :created
      else
        render json: { errors: card.errors }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Board not found" }, status: :not_found
    end

    def assign
      account = Current.account || Account.first
      Current.account ||= account if account

      card = Card.find(params[:id])
      card.assignments.destroy_all
      assignee = User.find(params[:assignee_id])
      card.assignments.create!(assignee: assignee, assigner: account.system_user)
      render json: card, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Card or assignee not found" }, status: :not_found
    end

    def move
      account = Current.account || Account.first
      Current.account ||= account if account

      card = Card.find(params[:id])
      column = Column.find(params[:column_id])
      card.column = column
      if card.save
        render json: card, status: :ok
      else
        render json: { errors: card.errors }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Card or column not found" }, status: :not_found
    end

    def update_full
      account = Current.account || Account.first
      Current.account ||= account if account

      card = Card.find(params[:id])
      if card.update(card_update_params)
        render json: card, status: :ok
      else
        render json: { errors: card.errors }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Card not found" }, status: :not_found
    end

    private
      def card_params
        params.expect(card: [ :title, :description, :image ])
      end

      def card_update_params
        params.expect(card: [ :title, :description, :image, :column_id ])
      end
  end
end
