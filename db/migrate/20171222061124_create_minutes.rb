class CreateMinutes < ActiveRecord::Migration[5.1]
  def change
    create_table :minutes do |t|
      t.datetime :time
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :vol_btc
      t.float :vol_currency
      t.float :weighted
    end
    add_index :minutes, :time,                unique: true
  end
end
