class CreateTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.text :word_pt
      t.references :unidade
      t.text :transl_eng
      t.text :transl_germ
      t.text :transl_span

      t.timestamps
    end
  end
end
