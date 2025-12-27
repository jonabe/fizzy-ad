module Factory
  class BoardsController < ApplicationController
    def create
      # Factory needs a default accountcontext. 
      # Since factory routes are not slugged, we must manually set Current.account.
      account = Account.first || Account.create_with_owner(account: { name: "Factory" }, owner: { email: "factory@autodev.local", password: "factory_secret" })
      
      Current.with_account(account) do
        board = Board.new(name: params[:name], description: params[:description])
        board.creator = account.system_user # Assign creator to system user

        if board.save
          render json: board, status: :created
        else
          render json: { errors: board.errors }, status: :unprocessable_entity
        end
      end
    end

    def update
      # Assuming single account for factory context
      account = Account.first
      
      Current.with_account(account) do
        board = Board.find(params[:id])
        # Support both direct params and nested board params
        attrs = params[:board] || params
        
        # Only include attributes that are present in params
        update_attrs = {}
        update_attrs[:name] = attrs[:name] if attrs.key?(:name)
        update_attrs[:description] = attrs[:description] if attrs.key?(:description)
        
        if board.update(update_attrs)
          render json: board, status: :ok
        else
          render json: { errors: board.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
