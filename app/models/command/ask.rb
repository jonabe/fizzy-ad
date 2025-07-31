class Command::Ask < Command
  store_accessor :data, :question, :card_ids

  def title
    "Ask '#{question}'"
  end

  def execute
    Current.user.resume_or_start_conversation(question)
    Command::Result::ShowModal.new(turbo_frame: "conversation", url: conversation_path)
  end
end
