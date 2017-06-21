class Token < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true

  def to_s
    id
  end
end
