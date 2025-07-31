class ConversationsController < ApplicationController
  def create
    Current.user.resume_or_start_conversation(question_params[:conversation][:question])
    redirect_to conversation_path, status: :see_other
  end

  def show
    @conversation = Current.user.conversation
  end

  private
    def conversation_params
      params.require(:conversation).permit(:question)
    end
end
