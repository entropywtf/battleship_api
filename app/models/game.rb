class Game < ApplicationRecord
  has_and_belongs_to_many :players
  has_many :scores

  validate :players_limit

  def players_limit
    if self.players.size != 2
      errors.add(:players, "Two players must be set.")
    end
  end
end
