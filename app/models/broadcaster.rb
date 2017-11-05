=begin
    t.string "name"
=end

class Broadcaster < ApplicationRecord
  has_many :programmes
end
