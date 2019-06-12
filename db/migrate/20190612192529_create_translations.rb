class CreateTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.text :word_pt
      t.references :unidade, foreign_key: true
      t.text :transl_eng
      t.text :transl_ger
      t.text :transl_spa

      t.timestamps
    end
  end
end
