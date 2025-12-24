class FixBoardDescriptionNullability < ActiveRecord::Migration[8.2]
  def change
    # Allow description to be null and set default empty string
    # This fixes the NOT NULL constraint from AddBoardMetadataSupport migration
    # while still supporting YAML metadata storage for API usage
    change_column_default :boards, :description, from: nil, to: ""
    change_column_null :boards, :description, true
  end
end
