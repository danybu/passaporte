class CreateUnidades < ActiveRecord::Migration[5.2]
  def change
    create_table :unidades do |t|
      t.text :title
      t.integer :book
      t.integer :nr

      t.timestamps
    end
  end
end
