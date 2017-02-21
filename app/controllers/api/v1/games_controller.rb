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
    end
  end
end
