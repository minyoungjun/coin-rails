class CreateCandledata < ActiveRecord::Migration[5.1]
  def change
    create_table :candledata do |t|
      t.integer :candlesize_id
      t.datetime :start_time
      t.datetime :end_time
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :vol_btc
      t.float :vol_currency
      t.float :weighted
      t.timestamps
    end
    add_index :candledata, :candlesize_id
    add_index :candledata, :start_time
    add_index :candledata, :end_time
  end
end
