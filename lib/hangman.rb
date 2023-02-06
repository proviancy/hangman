require 'yaml'

# Creates game object
class Game
  attr_reader :word,
              :game_over,
              :incorrect_guess_limit,
              :save_and_quit

  attr_accessor :guesses,
                :incorrect_guesses

  def initialize(word)
    @word = word.split('')
    @guesses = []
    @incorrect_guesses = 0
    @incorrect_guess_limit = 12
    @progress = Array.new(word.length, '_')
    @game_over = false
    @save_and_quit = false
  end

  def play_round
    display_incorrect_guesses
    display_guesses
    display_progress

    puts 'Type 1 to save and exit, or type a letter to guess:'
    guess = gets.chomp

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
    if guess.to_s == 1.to_s
      yaml_dump
      @game_over = true
      @save_and_quit = true
      return true
    end

    return false unless guess.length == 1 && guess =~ /[a-z]/

    return false if already_guessed?(guess)

    true
  end

  def reveal_letter(letter)
    @progress.each_with_index do |_space, index|
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
    saved_game = File.open('saved_game.yml', 'w')
    saved_game.puts YAML::dump(self)
    saved_game.close
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
resume_game = false

wordlist = File.open('wordlist.txt', 'r').readlines
wordlist.each do |word|
  word.chomp!
  valid_words << word if valid_word?(word)
end

if File.exist?('saved_game.yml')
  puts 'Would you like to load the existing game? (y/n)'
  case gets.chomp
  when 'y'
    game = YAML.load(File.read('saved_game.yml'), permitted_classes: [Game])
    File.delete('saved_game.yml')
    resume_game = true
    puts 'Loading saved game...'
  else
    puts 'Creating new game...'
  end
end

until quit
  unless resume_game
    game = Game.new(select_word(valid_words))
    puts 'Welcome to hangman! A random English word has been chosen for you to guess. Good luck!'
  end
  resume_game = false

  game.play_round until game.game_over

  if game.solved?
    puts "\nCongratulations! The word was '#{game.word.join('')}'."
    puts "You solved it with #{game.incorrect_guesses}/#{game.incorrect_guess_limit} incorrect guesses!"
  elsif game.save_and_quit
    puts 'Game saved. Goodbye!'
  else
    puts "\n\nGame over! The word was '#{game.word.join('')}'"
  end

  quit = true if game.save_and_quit

  unless game.save_and_quit
    puts "\nWould you like to play again? (y/n)"
    quit = true if gets.chomp == 'n'
  end
end

puts 'Thanks for playing!'
