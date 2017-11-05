class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.belongs_to :programme, index: true
      t.belongs_to :star, index: true
      t.timestamps
    end
  end
end
