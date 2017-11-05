=begin
    t.string "name"
    t.string "gender"
=end

class Star < ApplicationRecord
  has_many :contracts
  has_many :programmes, through: :contracts
end
