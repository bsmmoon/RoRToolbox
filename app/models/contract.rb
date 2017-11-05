=begin
    t.integer "programme_id"
    t.integer "star_id"
=end

class Contract < ApplicationRecord
  belongs_to :programme
  belongs_to :star
end
