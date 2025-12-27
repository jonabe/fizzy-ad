json.cache! card do
  json.(card, :id, :number, :title, :status)
  json.description card.description.to_plain_text
  json.description_html card.description.to_s
  json.image_url card.image.presence && url_for(card.image)

  json.tags card.tags.pluck(:title).sort

  json.closed card.closed?
  json.golden card.golden?
  json.last_active_at card.last_active_at.utc
  json.created_at card.created_at.utc

  json.url card_url(card)

  json.board card.board, partial: "boards/board", as: :board
  json.column card.column, partial: "columns/column", as: :column if card.column
  json.creator card.creator, partial: "users/user", as: :user

  json.comments_url card_comments_url(card)

  # Agent Lab Helpers
  json.column_name card.column.try(:name)
  json.column_position card.try(:position)
  json.assignee card.assignees.first, partial: "users/user", as: :user if card.assignees.any?
end
