=begin
    t.string "name"
    t.integer "broadcaster_id"
    t.integer "genre_id"
=end

class Programme < ApplicationRecord
  belongs_to :genre
  belongs_to :broadcaster
  has_many :contracts
  has_many :stars, through: :contracts
end
