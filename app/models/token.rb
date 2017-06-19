class Token < ApplicationRecord
  belongs_to :user

  def to_s
    id
  end
end
