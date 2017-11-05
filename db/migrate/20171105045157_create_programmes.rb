class CreateProgrammes < ActiveRecord::Migration[5.1]
  def change
    create_table :programmes do |t|
      t.string :name
      t.belongs_to :broadcaster, index: true
      t.belongs_to :genre, index: true
      t.timestamps
    end
  end
end
