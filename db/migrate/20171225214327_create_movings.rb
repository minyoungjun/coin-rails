class CreateMovings < ActiveRecord::Migration[5.1]
  def change

    add_index :movings , :candlesize_id
    add_index :movings, :start_time
    add_index :movings, :size
  end
end
