class TranslationsController < ApplicationController

  def lookup
    @word_to_lookup = params[:word_to_lookup]
    puts @word_to_lookup
    # @translation_trials = Transation.where("word_pt like %?%", @word_to_lookup)
    # puts @translation_trials
    
  end
end
