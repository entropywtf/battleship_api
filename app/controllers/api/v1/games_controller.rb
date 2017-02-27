module Api
  module V1
    class GamesController < ApplicationController
      def create
        @game = Game.new(player_ids: params[:player_ids], state: "init")
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
          render json: { message: "The player was not found on this game",
            status: :not_found }
        else
          board = Board.new(:game_id => @game.id, :player_id => player_id,
            :grid => Board.set_ships(params[:set_ships]))
          board.save
          render json: { status: :success }
        end
      end

      def leaderboard
        render json: Game.leaderboard
      end

      def start_game
        @game = Game.where(id: params[:id]).first
        if @game.blank?
          render json: { status: :not_found }
        elsif @game.state != "init"
          render json: { status: :unprocessable_entity,
            message: "This game has been already started." }
        elsif !Board.where(game_id: @game.id, player_id:
          [@game.player_ids]).exists?

          render json: { message: "Boards are not set up for players.",
            status: :success }
        else
          @game.player_ids.each{ |id| Score.create(game_id: @game.id,
            player_id: id, score: 0) }
          @game.state = "on"
          @game.turn_uid = @game.player_ids.first
          @game.save

          render json: {
            message: "Game started. Next turn: #{Player.find(@game.turn_uid).name}",
            status: :success }
        end
      end

      def pause_game
        @game = Game.find(params[:id])
        @game.state = "paused"
        @game.save
        render json: { message: "Game paused.", status: :success }
      end

      def resume_game
        @game = Game.find(params[:id])
        @game.state = "on"
        @game.save
        render json: {
          message: "Game resumed. Next turn: #{Player.find(@game.turn_uid).name}",
          status: :success }
      end

      def make_turn
        @game = Game.find(params[:id])
        player_id = params[:player_id].to_i
        if @game.state == "init"
          render json: { message: "Start a game first to know whose turn it is.",
            status: :success }
        elsif @game.turn_uid != player_id
          render json: { message: "This is not your turn.", status: :success }
        else
          opponent_id = @game.players.where.not(id: player_id)
          board = Board.where(game_id: @game.id, player_id: opponent_id).first
          msg = board.hit_cell(params[:cell], player_id)
          render json: { message: msg, status: :success }
        end
      end
    end
  end
end
