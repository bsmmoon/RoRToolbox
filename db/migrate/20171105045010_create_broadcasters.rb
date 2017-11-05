class CreateBroadcasters < ActiveRecord::Migration[5.1]
  def change
    create_table :broadcasters do |t|
      t.string :name
      t.timestamps
    end
  end
end
