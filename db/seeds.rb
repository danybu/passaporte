# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#VOCABULARY
require 'csv'


#Language codes
csv_options = { col_sep: ';', quote_char: '"', headers: :first_row }
filepath    = 'extra_material/seed_files/languages_living.csv'
CSV.foreach(filepath, csv_options) do |row|
  Language.create!(code:row[0][0..2], name:row[4]);
end
puts "Language codes loaded"

#unidades
filepath = "extra_material/seed_files/unidades.csv";
i=0;
unid={book:1}
CSV.foreach(filepath, csv_options) do |row|
  # binding.pry
  if i == 0
    unid[:nr] = row[0].delete("^0-9").to_s
    puts unid[:nr]
    puts unid[:nr].class
  elsif i == 2
    unid[:title] = row[0].split('..')[0].strip
    # puts "let us write"
    # puts nr
    # unid = {book:'1', nr:nr, title:title};
    puts unid
    Unidade.create!(unid)
  end
  i = i + 1
  i = 0 if i == 4
end
1.upto(10) do |i|
  Unidade.create!(book:'1', nr:'p'+i.to_s,title:"português em ação "+i.to_s)
end
Unidade.create!(book:'1', nr:'ac',title:"ac?")


#Scanned voc - a
filepath = 'extra_material/seed_files/scanned_voc_a.csv'
CSV.foreach(filepath, csv_options) do |row|
  word_pt = row[0]&.strip
  next if word_pt.nil? || word_pt==""
  unid_look_up = row[1]&.strip&.downcase
  next if unid_look_up.nil? || unid_look_up == ""
  # puts unid_look_up if unid_look_up.to_i.zero?
  unidade = Unidade.where("nr = ?",unid_look_up).first
  puts "#{word_pt} zit in unidade:"
  puts unidade.nr
  puts "#{unid_look_up} not found" if unidade.nil?
  eng = row[2]&.strip
  spa = row[3]&.strip
  ger = row[5]&.strip
  Translation.create!(
    word_pt:word_pt, 
    unidade:unidade,
    transl_eng:eng,
    transl_spa:spa,
    transl_ger:ger
    ) if !unidade.nil?
end
puts "scanned voc (starting with A) loaded"


units = Translation.select(:unidade_id).map(&:unidade_id).uniq.sort
# puts units