#read 
require 'json'

$filepath_nl = 'extra_material/seed_files/UserVocs/passaporte Vocab/'
$word_origins = {passaporte: {A1: {}, B1:{} }, others:{}}
# #extracting from VOCAB - A1 files: they have only the portuguese words, no translation, so the translations have to be extracted via a csv export of all vocab translations.
# def load_nl_A1_file(from,to)
#   chapter_string = "PP A1 #{from}-#{(to)}.txt"
#   puts chapter_string
#   pp_nl_serialized = File.read("#{$filepath_nl}#{chapter_string}")
#   pp_nl = JSON.parse(pp_nl_serialized)
#   # puts pp_nl
#   # binding.pry
#   vocab_file_name = "vocab_path: #{pp_nl["folders"][0]["path"]}"
#   puts vocab_file_name
#   pp_nl["folders"][0]["words"].each do |ppnl_pt_word|
#   end
# end

# def load_nl_A1_files
#   #grouped per 4
#   (0..7).each do |index|
#     load_nl_A1_file(index*4+1,index*4+4)
#   end
#   (0..3).each do |index|
#     load_nl_A1_file(33+2*index,34+2*index)
#   end
# end

# def load_nl_B1_files
#   (1..6).each do |index|
#     chapter_string = "PP B1 H#{index}.txt"
#     puts chapter_string
#     pp_nl_serialized = File.read("#{$filepath_nl}#{chapter_string}")
#     pp_nl = JSON.parse(pp_nl_serialized)
#     # puts pp_nl
#     # binding.pry
#     vocab_file_name = "vocab_path: #{pp_nl["folders"][0]["path"]}"
#     puts vocab_file_name
#     pp_nl["words"].each do |ppnl_line|
#       word_pt = ppnl_line["word"]
#       #TODO "o " en "a " afsplitsen
#       translation_array = ppnl_line["translations"]
#     end
#   end
# end

#
def construct_book_origins(folders)
  folders.each do |folder|
    if folder["words"].size > 0 
      book = folder["path"].split("/")[0]
      chapter = folder["path"].split("/")[1]
      if book == "Passaporte para Português 1"
        $word_origins[:passaporte][:A1][chapter] = {};
        $word_origins[:passaporte][:A1][chapter] = folder["words"].map {|raw_word| Translation.split_article_front(raw_word)}
      elsif book == "Passaporte para Português 2"
        $word_origins[:passaporte][:B1][chapter] = {};
        $word_origins[:passaporte][:B1][chapter] = folder["words"].map {|raw_word| Translation.split_article_front(raw_word)}
      else
        $word_origins[:others][book] = {} if $word_origins[:others][book].nil?
        $word_origins[:others][book][chapter] = folder["words"].map {|raw_word| Translation.split_article_front(raw_word)}
      end
    end
  end
end

def passaporte_unit?(wordhash)
  $word_origins[:passaporte][:A1].each do |chapter_key, chapter_value|
    chapter_value.each do |a1wordhash|
      return {book:"A1", chapter: chapter_key} if a1wordhash[:article]==wordhash[:article] && a1wordhash[:word]==wordhash[:word]
    end
  end
  $word_origins[:passaporte][:B1].each do |chapter_key, chapter_value|
    chapter_value.each do |b1wordhash|
      return {book:"B1", chapter: chapter_key} if b1wordhash[:article]==wordhash[:article] && b1wordhash[:word]==wordhash[:word]
    end
  end
  return nil
end

#loads all translations without unidade reference (aprender portugues and passaporte)
def load_vocab_translations
  pp_nl_serialized = File.read("#{$filepath_nl}alle danyvertalingen qff export.json")
  pp_nl = JSON.parse(pp_nl_serialized)

  #orgins of words: passaporte (and chapter) or other
  construct_book_origins(pp_nl["folders"])
  
  #saving the words to the database with reference to passaporte_words
  pp_nl["words"].each do |ppnl_line|
    word_pt_raw = ppnl_line["word"]
    word_pt_split = Translation.split_article_front(word_pt_raw)
    word_pt = word_pt_split[:word]
    genre_pt = word_pt_split[:article]
    # puts "for word_pt_split: #{word_pt_split}"
    passaporte_found = passaporte_unit?(word_pt_split)
    # puts "found?:"
    # puts passaporte_found
    pt_translation = nil
    if !passaporte_found.nil?
      pt_transl = Translation.find_by word_pt:word_pt_split[:word], genre_pt:word_pt_split[:article]
      # puts pt_transl
    end
    # puts "pt_transl:"
    # puts pt_transl
    translation_array = ppnl_line["translations"]
    save_nl_translation(word_pt, pt_transl, genre_pt,translation_array, ppnl_line["comments"])
  end
end

def save_nl_translation(word_pt, pt_translation, genre_pt, translation_array, comment)
  nl = Language.where('code = ?', 'dut')[0]
  unid_id = pt_translation&.unidade&.id || nil
  UserTranslation.create!(
    language:nl,
    translation:pt_translation,
    unidade_id:unid_id,
    word_pt:word_pt,
    genre_pt:genre_pt,
    main_transl:translation_array[0],
    alt_transl_1:translation_array[1],
    alt_transl_2:translation_array[2],
    alt_transl_3:translation_array[3],
    comment:comment
    )
end

def load_all_nl_files
  load_vocab_translations
end