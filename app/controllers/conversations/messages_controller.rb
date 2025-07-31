class Conversations::MessagesController < ApplicationController
  def create
    Current.user.resume_or_start_conversation(message_params[:content])
    head :no_content
  end

  private
    def message_params
      params.require(:conversation_message).permit(:content)
    end
end
