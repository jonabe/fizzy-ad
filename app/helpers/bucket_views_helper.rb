module BucketViewsHelper
  def bucket_view_form(path, method:, id:)
    form_tag path, method: method, id: id do
      concat hidden_field_tag(:order_by, params[:order_by])
      concat hidden_field_tag(:status, params[:status])

      Array(params[:assignee_ids]).each do |assignee_id|
        concat hidden_field_tag("assignee_ids[]", assignee_id, id: nil)
      end

      Array(params[:tag_ids]).each do |tag_id|
        concat hidden_field_tag("tag_ids[]", tag_id, id: nil)
      end
    end
  end
end
