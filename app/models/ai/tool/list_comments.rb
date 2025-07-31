class Ai::Tool::ListComments < RubyLLM::Tool
  description <<-MD
    Lists all comments accessible by the current user.
    The response is paginated so you may need to iterate through multiple pages to get the full list.
    Responses are JSON objects that look like this:
    ```
    {
      "collections": [
        {
          "id": 3,
          "card_id": 5,
          "body": "This is a comment",
          "created_at": "2023-10-01T12:00:00Z",
          "creator": { "id": 1, "name": "John Doe" },
          "reactions": [
            { "content": "👍", "reacter": { "id": 2, "name": "Jane Doe" } }
          ]
      ],
      "pagination": {
        "next_page": "e3c2gh75e4..."
      }
    }
    ```
    Each collection object has the following fields:
    - id [Integer, not null]
    - name [String, not null]
  MD

  param :page,
    type: :string,
    desc: "Which page to return. Leave balnk to get the first page",
    required: false

  def execute(page: nil)
    page = GearedPagination::Recordset.new(
      Comment.all.preload(:card, :creator, reactions: [ :reacter ]),
      ordered_by: { created_at: :asc, id: :desc }
    ).page(page)

    {
      collections: page.records.map do |comment|
        {
          id: comment.id,
          card_id: comment.card_id,
          body: comment.body.to_plain_text,
          created_at: comment.created_at.iso8601,
          creator: comment.creator.as_json(only: [ :id, :name ]),
          reactions: comment.reactions.map do |reaction|
            {
              content: reaction.content,
              reacter: reaction.reacter.as_json(only: [ :id, :name ])
            }
          end
        }
      end,
      pagination: {
        next_page: page.next_param
      }
    }.to_json
  end
end
