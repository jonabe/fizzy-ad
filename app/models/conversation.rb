class Conversation < ApplicationRecord
  broadcasts_refreshes

  belongs_to :user
  has_many :messages, dependent: :destroy

  enum :state, %w[ ready thinking ].index_by(&:itself), default: :ready

  def price
    messages.pluck(:price_microcents).compact.sum.to_d / 100_000
  end

  def clear
    messages.delete_all
    touch
  end

  def ask(question)
    raise ArgumentError, "Question cannot be blank" if question.blank?

    with_lock do
      return false if thinking?

      thinking!
      messages.create!(role: :user, content: question)
    end
  end

  def respond(answer, **attributes)
    raise ArgumentError, "Answer cannot be blank" if answer.blank?

    with_lock do
      return false unless thinking?

      messages.create!(**attributes, role: :assistant, content: answer)
      ready!
    end
  end
end
