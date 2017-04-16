class Notice < ApplicationRecord
  validates :text, presence: true
end
