class Sighting < ApplicationRecord
  validates :user_id, presence: true
  validates :bird_id, presence: true, uniqueness: { scope: :user_id, message: "bird already recorded" }

  belongs_to :bird
  belongs_to :user
end
