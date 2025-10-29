module Column::Positioned
  extend ActiveSupport::Concern

  included do
    scope :sorted, -> { order(position: :asc) }

    before_create :set_position
  end

  def move_left
    if column = collection.columns.where("position < ?", position).sorted.last
      swap_position_with(column)
    end
  end

  def move_right
    if column = collection.columns.where("position > ?", position).sorted.first
      swap_position_with(column)
    end
  end

  private
    def set_position
      max_position = collection.columns.maximum(:position)
      self.position = max_position + 1
    end

    def swap_position_with(other_column)
      transaction do
        other_column.position, self.position = self.position, other_column.position
        other_column.save!
        save!
      end
    end
end
