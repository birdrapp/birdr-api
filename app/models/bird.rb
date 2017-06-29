class Bird < ApplicationRecord
  validates :common_name, presence: true, length: { maximum: 255 }
  validates :scientific_name, presence: true, length: {maximum: 255 },
                              uniqueness: { case_sensitive: false }

  has_many :sightings, dependent: :destroy
end
