class Board < ApplicationRecord
  serialize :grid, Array
  belongs_to :player
  belongs_to :game

  def set_ships(ships_coordinates)
    check_ships_coordinates(ships_coordinates.to_h)
    byebug
    ships_coordinates.each do |type, c_arr|
      c_arr.each do |coord|
        row, column = coord.split(//)
        row = letter_to_number(row)
        self.grid[row][column.to_i]=type
      end
    end
 # rescue => e
 #   errors.add(:grid, "Following exception caught: #{e.message}")
  end

  def letter_to_number(letter)
    letters = ("a".."j").to_a
    numbers = (0..9).to_a
    l_n_mapping = Hash[letters.zip(numbers)]
    return l_n_mapping[letter]
  end

  def check_ships_coordinates(ships)
    types = { :carrier => 5, :battleship => 4, :cruiser => 3, :destroyer1 => 2,
      :destroyer2 => 2, :submarine1 => 1, :submarine2 => 1 }
    if ships.any?{ |type, size| types[type].size != size }
      errors.add(:grid, "Wrong ship size.")
      return
    elsif types.keys.any?{ |type| ships[type].nil? }
      errors.add(:grid, "Missing type of ship.")
      return
      # XXX: further checks on ships params
    end
  end
end
