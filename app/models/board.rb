class Board < ApplicationRecord
  include Accessible, AutoPostponing, Board::Storage, Broadcastable, Cards, Entropic, Filterable, Publishable, ::Storage::Tracked, Triageable

  belongs_to :creator, class_name: "User", default: -> { Current.user }
  belongs_to :account, default: -> { creator.account }

  has_rich_text :public_description

  validate :valid_yaml_metadata

  has_many :tags, -> { distinct }, through: :cards
  has_many :events
  has_many :webhooks, dependent: :destroy
  has_many :columns, dependent: :destroy

  after_create :create_default_columns

  scope :alphabetically, -> { order("lower(name)") }
  scope :ordered_by_recently_accessed, -> { merge(Access.ordered_by_recently_accessed) }

  # Parse YAML metadata from description field
  # Used by Factory CLI and Agent Lab for storing repo_url, workspace_path, container_id
  def metadata
    return {} if description.blank?
    YAML.safe_load(description, permitted_classes: [Symbol], aliases: true) || {}
  rescue Psych::SyntaxError
    {}
  end

  # Set metadata by converting hash to YAML for storage in description field
  def metadata=(hash)
    self.description = hash.to_yaml
  end

  private
    def valid_yaml_metadata
      return if description.blank?
      YAML.safe_load(description, permitted_classes: [Symbol], aliases: true)
    rescue Psych::SyntaxError => e
      errors.add(:description, "must be valid YAML: #{e.message}")
    end

    def create_default_columns
      %w[Backlog Ready In\ Progress Review Done].each do |name|
        columns.create!(name: name)
      end
    end
end
