class CreateCoins < ActiveRecord::Migration[5.1]
  def change
    create_table :coins do |t|

      t.timestamps
    end
  end
end
