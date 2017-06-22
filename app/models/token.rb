class Token < ApplicationRecord
  attribute :expires_at, default: -> { Time.now + 90.days }

  validates :user_id, presence: true
  validates :expires_at, presence: true

  belongs_to :user

  scope :unexpired, -> { where("expires_at > ?", Time.now) }

  def to_s
    id
  end
end
