class CreateWrappings < ActiveRecord::Migration
  def change
    create_table :wrappings do |t|
      t.string :name
      t.belongs_to :present, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
