class Comment < ApplicationRecord
  include Searchable, Messageable

  belongs_to :creator, class_name: "User", default: -> { Current.user }

  searchable_by :body_plain_text, using: :comments_search_index, as: :body

  has_markdown :body
end
