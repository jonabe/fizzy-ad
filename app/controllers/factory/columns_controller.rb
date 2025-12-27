module Factory
  class ColumnsController < ApplicationController
    def create
      # Factory needs a default account context
      account = Account.first
      
      Current.with_account(account) do
        board = Board.find(params[:board_id])
        column = board.columns.new(name: params[:name], position: params[:position])
        
        if column.save
          render json: column, status: :created
        else
          render json: { errors: column.errors }, status: :unprocessable_entity
        end
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Board not found" }, status: :not_found
    end
  end
end
