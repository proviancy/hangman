require 'yaml'

# Creates game object
class Game
  attr_reader :word,
              :game_over,
              :incorrect_guess_limit

  attr_accessor :guesses,
                :incorrect_guesses

  def initialize(word)
    @word = word.split('')
    @guesses = []
    @incorrect_guesses = 0
    @incorrect_guess_limit = 12
    @progress = Array.new(word.length, '_')
    @game_over = false
  end

  def play_round
    display_incorrect_guesses
    display_guesses
    display_progress

    puts 'Type 1 to save and exit, or type a letter to guess:'
    guess = gets.chomp

    yaml_dump if guess == 1.to_s

    until valid_guess?(guess)
      puts 'Invalid guess. Try again:'
      guess = gets.chomp
    end

    take_guess(guess)
    @game_over = true if solved? || @incorrect_guesses >= @incorrect_guess_limit
  end

  def solved?
    return false if @progress.include?('_')

    true
  end

  private

  def already_guessed?(guess)
    @guesses.include?(guess)
  end

  def contains_letter?(letter)
    @word.include?(letter)
  end

  def display_progress
    puts "\n#{@progress.join(' ')}"
  end

  def display_guesses
    puts "\nGuesses: #{@guesses.join(', ')}"
  end

  def display_incorrect_guesses
    puts "\nIncorrect Guesses: #{@incorrect_guesses}/#{@incorrect_guess_limit}"
  end

  def valid_guess?(guess)
    return false unless guess.length == 1 && guess =~ /[a-z]/

    return false if already_guessed?(guess)

    true
  end

  def reveal_letter(letter)
    @progress.each_with_index do |space, index|
      @progress[index] = letter if @word[index] == letter
    end
  end

  def take_guess(letter)
    if contains_letter?(letter)
      reveal_letter(letter)
    else
      @incorrect_guesses += 1
    end
    @guesses << letter
    @guesses.sort!
  end

  def yaml_dump
    puts YAML::dump(self)
  end
end

def valid_word?(word)
  return true if word.length >= 5 && word.length <= 12

  false
end

def select_word(valid_words)
  valid_words[rand(valid_words.length - 1)]
end

valid_words = []
quit = false

wordlist = File.open('wordlist.txt', 'r').readlines
wordlist.each do |word|
  word.chomp!
  valid_words << word if valid_word?(word)
end

until quit
  game = Game.new(select_word(valid_words))

  game.play_round until game.game_over

  if game.solved?
    puts "\nCongratulations! The word was '#{game.word.join('')}'."
    puts "You solved it with #{game.incorrect_guesses}/#{game.incorrect_guess_limit} incorrect guesses!"
  else
    puts "\n\nGame over! The word was '#{game.word.join('')}'"
  end

  puts "\nWould you like to play again? (y/n)"
  quit = true if gets.chomp == 'n'
end

puts 'Thanks for playing!'
