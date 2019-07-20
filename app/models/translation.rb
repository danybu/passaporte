class Translation < ApplicationRecord
  belongs_to :unidade, optional: true

  def self.valid_pt_articles
    return ["o","a","os","as"]
  end

  #split methods
  def self.split_article_behind(to_split)
    words = to_split.split(",")
    # puts words
    if self.valid_pt_articles.include?(words.last.strip)
      # binding.pry
      res_article = words.pop.strip
      res_word = words[0].strip
      return {article: res_article, word: res_word }
    elsif words.last.strip == "o/a" || words.last.strip == "os/as"
      #not valid articles but should be recognised by the calling method to make 2 different word entries (1 male, 1 female)
      res_article = words.pop.strip
      res_word = words[0].strip
      return {article: res_article, word: res_word.strip }
    else
      return {article: nil, word: to_split.strip}
    end
  end

  def self.split_article_front(to_split)
    words = to_split.split(" ")
    if self.valid_pt_articles.include?(words.first.strip) || words.last.strip == "o/a" || words.last.strip == "os/as"
      res_article = words.shift.strip
      res_word = words.join(" ").strip
      return {article: res_article, word: res_word.strip}
    else
      return {article: nil, word: to_split.strip}
    end
  end

end
