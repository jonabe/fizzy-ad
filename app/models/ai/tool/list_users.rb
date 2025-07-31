class Ai::Tool::ListUsers < RubyLLM::Tool
  description <<-MD
    Lists all users accessible by the current user.
    The response is paginated so you may need to iterate through multiple pages to get the full list.
    Responses are JSON objects that look like this:
    ```
    {
      "collections": [
        { "id": 3, "name": "John Doe" },
        { "id": 4, "name": "Johanna Doe" }
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
      User.all,
      ordered_by: { name: :asc, id: :desc }
    ).page(page)

    {
      collections: page.records.map do |user|
        {
          id: user.id,
          name: user.name
        }
      end,
      pagination: {
        next_page: page.next_param
      }
    }.to_json
  end
end
