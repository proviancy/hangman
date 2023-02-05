require 'yaml'

class Game
  attr_reader :word,
  attr_accessor :guesses,
                :incorrect_guesses

  @guesses = []
  @incorrect_guesses = 0

  def initialize(word)
    @word = word
  end
end

def clean_wordlist!(wordlist)
  # Remove words less than 5 or more than 12 characters
end

def select_word
  # Randomly select word
end

wordlist_file = File.open("wordlist.txt", "r")
wordlist = wordlist_file.readlines

wordlist.each do |word| 
  word.chomp!
end 

p wordlist