class Sighting < ApplicationRecord
  validates :user_id, presence: true
  validates :bird_id, presence: true

  belongs_to :bird
  belongs_to :user
end
