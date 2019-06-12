class CreateUnidades < ActiveRecord::Migration[5.2]
  def change
    create_table :unidades do |t|
      t.text :title
      t.text :book
      t.text :nr

      t.timestamps
    end
  end
end
