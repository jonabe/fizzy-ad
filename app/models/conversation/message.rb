class Conversation::Message < ApplicationRecord
  has_rich_text :content

  belongs_to :conversation, inverse_of: :messages

  enum :role, %w[ user assistant ].index_by(&:itself)

  after_create_commit :generate_response_later, if: :user?

  def generate_response_later
    Conversation::ResponseGeneratorJob.perform_later(self)
  end

  def generate_response
    response = Conversation::ResponseGenerator.new(self).generate

    message_attributes = {
      model_id: response.model_id,
      input_tokens: response.input_tokens,
      output_tokens: response.output_tokens,
      input_cost_microcents: response.input_cost_microcents,
      output_cost_microcents: response.output_cost_microcents,
      cost_microcents: response.cost_microcents
    }

    conversation.respond(response.answer, **message_attributes)
  end

  def to_llm
    RubyLLM::Message.new(
      role: role.to_sym,
      content: content.to_plain_text,
      tool_calls: nil,
      tool_call_id: nil,
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      model_id: model_id
    )
  end
end
