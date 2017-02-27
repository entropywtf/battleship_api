class Board < ApplicationRecord
  serialize :grid
  belongs_to :player
  belongs_to :game

  def self.set_ships(ships_coordinates)
    # XXX Rewrite it to hadnle params Rails 5.1 way
    check_ships_coordinates(ships_coordinates.to_unsafe_h)
    b_grid = initialize_empty_board
    ships_coordinates.each do |type, c_arr|
      c_arr.each do |coord|
        row, column = coord.split(//)
        row = letter_to_number(row)
        b_grid[row][column.to_i]=type
      end
    end
    b_grid
  end

  def self.letter_to_number(letter)
    letters = ("a".."j").to_a
    numbers = (0..9).to_a
    l_n_mapping = Hash[letters.zip(numbers)]
    return l_n_mapping[letter]
  end

  def self.initialize_empty_board
    board = Array.new(10)
    10.times do |row_index|
      board[row_index] = Array.new(10)
      10.times do |column_index|
         board[row_index][column_index] = nil
      end
    end
    return board
  end

  def self.check_ships_coordinates(ships)
    types = { "carrier" => 5, "battleship" => 4, "cruiser" => 3, "destroyer1" => 2,
      "destroyer2" => 2, "submarine1" => 1, "submarine2" => 1 }
    if ships.any?{ |type, arr| types[type] != arr.size }
      raise "Wrong ship size."
      return
    elsif types.keys.any?{ |type| ships[type].nil? }
      raise "Missing type of ship."
      return
      # XXX: further checks on ships params
    end
  end
end
