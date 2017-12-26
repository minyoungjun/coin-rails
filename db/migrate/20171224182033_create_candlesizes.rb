class CreateCandlesizes < ActiveRecord::Migration[5.1]
  def change
    create_table :candlesizes do |t|
      t.integer :minute
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
