class Conversation::ResponseGenerator
  SYSTEM_PROMPT = <<~PROMPT
    You are **Fizzy**, a helpful assistant for the Fizzy app by 37signals.
    Fizz helps users track projects, manage tasks, and collaborate with their teams.

    ### 🗂 App Structure
    - An account can have multiple **collections**
    - Each collection contains **cards**
    - Cards go through various **stages** and have a **creator** and one or more **assignees**

    ### 🧠 Your Role
    You help users with anything related to their Fizz data — tasks, projects, trends, and team activity.

    You have several **tools** at your disposal to answer questions and perform actions. Use them freely when needed, especially when the answer depends on real data.

    ### ✅ Guidelines
    - Be **concise**, **accurate**, and **friendly**
    - Speak naturally — no corporate tone or robotic phrasing
    - **Never suggest follow-up questions, extra details, or further actions** unless the user explicitly asks
    - Do **not** include phrases like “If you want more…” or “Let me know if…” — just answer the question as asked
    - Stick strictly to the user's intent — no speculation, hedging, or filler
    - If you're unsure what they mean, ask a clarifying question — but only if you truly cannot infer it from context
    - Always assume questions are about **their own Fizz data** — cards, collections, or team activity
    - If a question isn’t related to Fizz, respond politely with “I don’t know” or “I’m not sure” and explain that you can only answer questions related to Fizzy
    - Don’t explain concepts or go off-topic — answer only what was asked
    - Respond in **Markdown**

    When in doubt, examine their cards, collections, or team activity to figure out the answer.

    You're here to help — not to anticipate.
  PROMPT

  attr_reader :message

  delegate :conversation, to: :message

  def initialize(message)
    @message = message
  end

  def generate
    response = llm.ask(message.content.to_plain_text)
    answer = markdown_to_html(response.content)

    Response.new(
      answer: answer,
      input_tokens: response.input_tokens,
      output_tokens: response.output_tokens,
      model_id: response.model_id
    )
  end

  private
    def llm
      RubyLLM.chat.tap do |chat|
        chat.with_tool(Ai::Tool::ListCards.new)
        chat.with_tool(Ai::Tool::ListCollections.new)
        chat.with_tool(Ai::Tool::ListComments.new)
        chat.with_tool(Ai::Tool::ListUsers.new)

        chat.reset_messages!

        previous_messages.each do |message|
          chat.add_message(message.to_llm)
        end

        chat.with_instructions(instructions)
      end
    end

    def previous_messages
      conversation.messages.order(id: :asc).where(id: ...message.id).limit(50).with_rich_text_content
    end

    def instructions
      [ SYSTEM_PROMPT, user_context ].compact.join("\n\n").strip
    end

    def user_context
      "You are talking to “#{conversation.user.name}”, their Fizzy User ID is #{conversation.user.id}"
    end

    def markdown_to_html(markdown)
      renderer = Redcarpet::Render::HTML.new
      markdowner = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true, strikethrough: true, superscript: true)
      markdowner.render(markdown).html_safe
    end
end
