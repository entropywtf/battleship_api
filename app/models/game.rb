class Game < ApplicationRecord
  has_and_belongs_to_many :players
  has_many :scores

  validate :players_limit

  def players_limit
    if self.players.size != 2
      errors.add(:players, "Two players must be set.")
    end
  end

  def self.leaderboard
    sql = <<EOF
SELECT DISTINCT p.name, COUNT(g.*) AS games_won
FROM players p
LEFT OUTER JOIN games_players gp
ON gp.player_id=p.id
LEFT OUTER JOIN games g
ON g.id=gp.game_id
WHERE g.winner_uid IS NOT NULL
AND g.winner_uid=p.id
GROUP BY p.name
ORDER BY games_won DESC;
EOF
    return ActiveRecord::Base.connection.execute(sql).to_a
  end
end
