class CreateStars < ActiveRecord::Migration[5.1]
  def change
    create_table :stars do |t|
      t.string :name
      t.string :gender
      t.timestamps
    end
  end
end
