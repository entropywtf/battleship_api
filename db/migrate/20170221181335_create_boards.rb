class CreateBoards < ActiveRecord::Migration[5.0]
  def change
    create_table :boards do |t|
      t.integer :player_id
      t.integer :game_id
      t.text :grid, array: true, default: empty_board
      t.timestamps
    end
  end

  def empty_board
    board = Array.new(10)
    10.times do |row_index|
      board[row_index] = Array.new(10)
      10.times do |column_index|
         board[row_index][column_index] = nil
      end
    end
    return board
  end
end
