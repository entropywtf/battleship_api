module Api
  module V1
    class PlayersController < ApplicationController
      def create
        player = Player.new(name: params[:name])
        if player.save
          render json: player, status: :created
        else
          render json: player.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
