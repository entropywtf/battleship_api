module Api
  module V1
    class GamesController < ApplicationController
      def create
        @game = Game.new(player_ids: params[:player_ids])
        if @game.save
          render json: @game, status: :created
        else
          render json: @game.errors, status: :unprocessable_entity
        end
      end

      def score
        @game = Game.find(params[:id])
        current_score = Score.where(:game_id => @game.id).
          joins(:player).pluck(:name, :player_id, :score)

        render json: { is_over: @game.winner_uid.present?,
          score: current_score,  status: :success }
      end

      def add_board
        @game = Game.find(params[:id])
        player_id = params[:player_id]
        if !@game.player_ids.include?(player_id.to_i)
          render json: "The player was not found on this game",
            status: :not_found
        else
          board = Board.new(:game_id => @game.id, :player_id => player_id,
            :grid => Marshal.dump(Board.initialize_empty_board))
          render json: board.save, status: :success
        end
      end

      def leaderboard
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
        result = ActiveRecord::Base.connection.execute(sql).to_a
        render json: result
      end
    end
  end
end
