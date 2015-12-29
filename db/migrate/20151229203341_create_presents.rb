class CreatePresents < ActiveRecord::Migration
  def change
    create_table :presents do |t|
      t.string :name
      t.decimal :price
      t.boolean :regifted
      t.integer :receiver
      t.integer :giver

      t.timestamps null: false
    end
  end
end
