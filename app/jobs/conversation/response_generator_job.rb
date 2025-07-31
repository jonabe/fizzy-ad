class Conversation::ResponseGeneratorJob < ApplicationJob
  def perform(message)
    message.generate_response
  end
end
