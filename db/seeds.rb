require 'csv'
require 'set'
require_relative 'nl_translations'

#Language codes
#==============
csv_options = { col_sep: ';', quote_char: '"', headers: :first_row }
filepath    = 'extra_material/seed_files/languages_living.csv'
CSV.foreach(filepath, csv_options) do |row|
  Language.create!(code:row[0][0..2], name:row[4]);
end
puts "Language codes loaded"

#unidades
#========
#A1-A2
filepath = "extra_material/seed_files/unidades.csv";
i=0;
unid={book:1}
CSV.foreach(filepath, csv_options) do |row|
  # binding.pry
  if i == 0
    unid[:nr] = row[0].delete("^0-9").to_s
    # puts unid[:nr]
    # puts unid[:nr].class
  elsif i == 2
    unid[:title] = row[0].split('..')[0].strip
    # puts "let us write"
    # puts nr
    # unid = {book:'1', nr:nr, title:title};
    # puts unid
    Unidade.create!(unid)
  end
  i = i + 1
  i = 0 if i == 4
end
1.upto(10) do |i|
  Unidade.create!(book:'1', nr:'p'+i.to_s,title:"Português em ação "+i.to_s)
end
0.upto(9) do |i|
  start_chap = (i*4+1).to_s
  end_chap = (i*4+4).to_s
  Unidade.create!(book:'1', nr:'r'+start_chap,title:"Revisão unidades #{start_chap} até #{end_chap}")
end
Unidade.create!(book:'1', nr:'ac',title:"atividades de comunicação")

#B1
filepath="extra_material/seed_files/Unidades B1.csv"
csv_options = { col_sep: ';', quote_char: '"' }
CSV.foreach(filepath, csv_options) do |row|  
  Unidade.create!(book:2,nr:row[0].strip.downcase,title:row[1].strip)
end



#scanned vocabulary PP: A1/A2
#=============================
filepath = 'extra_material/seed_files/vocab A1 opgekuist v2.txt';
other_separators = Set.new

File.open(filepath).each_with_index do |voc_line, ind|
  #1 structuur: pt_word <hoofdstuk> eng_transl
  #statistiekvorming:
  separators = voc_line.match(/\b\w*\d+\w*/).to_a
  splitArray = voc_line.split(/\b\w*\d+\w*/)
  if separators.size == 0
    #is it AC?
    splitArray = voc_line.split(" AC ")
    if splitArray.size == 2
      separator = "AC"
    else
     puts "problems finding separator for line #{ind}: "
     puts voc_line
   end
 elsif separators.size >= 2
  puts "more than 2 separators found for line #{ind}: "
  puts voc_line
  else #OK!!
    separator = separators[0].strip
    other_separators.add(separator) if !(separator =~ /\b[0-9]+/)
    word_pt_raw = splitArray[0]&.strip
    word_pt_split = Translation.split_article_behind(word_pt_raw)
    word_pt = word_pt_split[:word]
    genre_pt = word_pt_split[:article]
    next if word_pt.nil? || word_pt==""
    unid_look_up = separator&.strip&.downcase
    next if unid_look_up.nil? || unid_look_up == ""
    # puts unid_look_up if unid_look_up.to_i.zero?
    unidade = Unidade.where("nr = ?",unid_look_up).first
    # puts "#{word_pt} zit in unidade:"
    # puts unidade.nr
    puts "#{unid_look_up} not found" if unidade.nil?
    eng = splitArray[1]&.strip
    genre_pt = 'verb' if eng[0..2] == 'to '
    if genre_pt == "o/a" && !unidade.nil?
      # binding.pry
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'o',
        unidade:unidade,
        transl_eng:"#{eng} (male)",
        transl_spa:nil,
        transl_ger:nil
        )
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'a',
        unidade:unidade,
        transl_eng:"#{eng} (female)",
        transl_spa:nil,
        transl_ger:nil
        )
    elsif genre_pt == "os/as" && !unidade.nil?
      binding.pry
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'os',
        unidade:unidade,
        transl_eng:"#{eng} (male)",
        transl_spa:nil,
        transl_ger:nil
        )
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'as',
        unidade:unidade,
        transl_eng:"#{eng} (female)",
        transl_spa:nil,
        transl_ger:nil
        )
    else
      Translation.create!(
        word_pt:word_pt,
        genre_pt:genre_pt,
        unidade:unidade,
        transl_eng:eng,
        transl_spa:nil,
        transl_ger:nil
        ) if !unidade.nil?
    end
  end
end

#scanned vocab: B1 (problem: no unidade information)
#step 1: load words per chapter
words = []
filepath = 'extra_material/seed_files/b1 words per chapter'
chapter = 1
File.open(filepath).each do |vocline|
  vocline.strip!
  if vocline =~ /\b\w*\d+\w*/ 
    chapter=vocline.downcase
  else
    # strip article: can be in front or in back
    step1 = Translation.split_article_behind(vocline)[:word]
    word = Translation.split_article_front(step1)[:word]
    words<<{chapter: chapter, word:word}
  end
end
# puts words
filepath = 'extra_material/seed_files/B1 volledig opgekuist utf8.csv';
csv_options = { col_sep: ';', quote_char: '"', headers: :first_row }
CSV.foreach(filepath, csv_options) do |row|
  word_pt_raw = row[0]
  eng = row[1].strip
  word_pt_split = Translation.split_article_behind(word_pt_raw)
  word_pt = word_pt_split[:word]
  genre_pt = word_pt_split[:article]
  genre_pt = 'verb' if eng[0..2] == 'to '
  unid_str = nil
  words.each do |b1unid|
    if b1unid[:word] == word_pt
      unid_str = b1unid[:chapter].to_s
      break
    end
  end
  # binding.pry
  if unid_str
    unid = Unidade.where(book:2,nr:unid_str.downcase).first
    puts "unid not found for #{unid_str}" if unid.nil?
    puts "#{word_pt} in #{unid[:book]}, #{unid[:nr]}: #{unid[:title]}"
  else
    puts "#{word_pt} not in B1"
    Translation.where("? LIKE ?",:word_pt,word_pt+"%").each do |w|
      puts w
    end
  end
  if genre_pt == "o/a" 
      # binding.pry
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'o',
        unidade:unid,
        transl_eng:"#{eng} (male)",
        transl_spa:nil,
        transl_ger:nil
        )
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'a',
        unidade:unid,
        transl_eng:"#{eng} (female)",
        transl_spa:nil,
        transl_ger:nil
        )
    elsif genre_pt == "os/as" && !unidade.nil?
      binding.pry
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'os',
        unidade:unid,
        transl_eng:"#{eng} (male)",
        transl_spa:nil,
        transl_ger:nil
        )
      Translation.create!(
        word_pt:word_pt,
        genre_pt:'as',
        unidade:nil,
        transl_eng:"#{eng} (female)",
        transl_spa:nil,
        transl_ger:nil
        )
    else
      Translation.create!(
        word_pt:word_pt,
        genre_pt:genre_pt,
        unidade:nil,
        transl_eng:eng,
        transl_spa:nil,
        transl_ger:nil
        )
    end
  end


  load_all_nl_files
