module User::Conversational
  extend ActiveSupport::Concern

  included do
    has_one :conversation, dependent: :destroy
  end

  def resume_or_start_conversation(question = nil)
    (conversation || create_conversation).tap do |conversation|
      conversation.ask(question) if question.present?
    end
  end
end
