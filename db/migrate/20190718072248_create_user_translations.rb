class CreateUserTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :user_translations do |t|
      t.references :language, foreign_key: true
      t.references :translation, foreign_key: true
      t.references :unidade, foreign_key: true
      t.text :word_pt
      t.text :genre_pt
      t.text :main_transl
      t.text :alt_transl_1
      t.text :alt_transl_2
      t.text :alt_transl_3
      t.text :comment

      t.timestamps
    end
  end
end
