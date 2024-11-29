module ActionText
  module HasMarkdown
    extend ActiveSupport::Concern

    class_methods do
      def has_markdown(name, strict_loading: strict_loading_by_default)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}
            markdown_#{name} || build_markdown_#{name}
          end

          def #{name}_html
            #{name}.to_html
          end

          def #{name}_plain_text
            #{name}.to_plain_text
          end

          def #{name}?
            markdown_#{name}.present?
          end

          def #{name}=(content)
            self.#{name}.content = content
          end
        CODE

        has_one :"markdown_#{name}", -> { where(name: name) },
          class_name: "ActionText::Markdown", as: :record, inverse_of: :record, autosave: true, dependent: :destroy,
          strict_loading: strict_loading

        scope :"with_markdown_#{name}", -> { includes("markdown_#{name}") }
      end
    end

    def safe_markdown_attribute(name)
      if self.class.reflect_on_association("markdown_#{name}")&.klass == ActionText::Markdown
        public_send(name)
      end
    end
  end
end

ActiveSupport.on_load :active_record do
  include ActionText::HasMarkdown
end
