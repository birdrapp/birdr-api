class Token < ApplicationRecord
  attribute :expires_at, default: -> { Time.now + 30.days }

  validates :user_id, presence: true
  validates :expires_at, presence: true

  belongs_to :user

  def to_s
    id
  end
end
