module Factory
  class BoardsController < ApplicationController
    def create
      account = Current.account || Account.first ||
        Account.create_with_owner(
          account: { name: "Factory" },
          owner: { email: "factory@autodev.local", password: "factory_secret" }
        )
      Current.account ||= account

      board = Board.new(name: params[:name], description: params[:description])
      board.creator = account.system_user

      if board.save
        render json: board, status: :created
      else
        render json: { errors: board.errors }, status: :unprocessable_entity
      end
    end

    def update
      account = Current.account || Account.first
      Current.account ||= account if account

      board = Board.find(params[:id])
      attrs = params[:board] || params

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
