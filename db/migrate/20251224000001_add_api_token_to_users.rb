class AddApiTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :api_token, :string, limit: 32
    # Note: role column already exists in Fizzy schema (db/schema.rb:766)

    add_index :users, :api_token, unique: true
  end
end
