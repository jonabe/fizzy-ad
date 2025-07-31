class Ai::Tool::ListCollections < RubyLLM::Tool
  description <<-MD
    Lists all collections accessible by the current user.
    The response is paginated so you may need to iterate through multiple pages to get the full list.
    Responses are JSON objects that look like this:
    ```
    {
      "collections": [
        { "id": 3, "name": "Foo" },
        { "id": 4, "name": "Bar" }
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
    puts "= TOOL CALL: ListCollections"

    page = GearedPagination::Recordset.new(
      Collection.all,
      ordered_by: { name: :asc, id: :desc }
    ).page(page)

    {
      collections: page.records.map do |collection|
        {
          id: collection.id,
          name: collection.name
        }
      end,
      pagination: {
        next_page: page.next_param
      }
    }.to_json
  end
end
