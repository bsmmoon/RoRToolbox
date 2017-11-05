=begin
    t.string "name"
=end

class Genre < ApplicationRecord
  has_many :programmes
end
