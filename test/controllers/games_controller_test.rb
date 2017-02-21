require 'test_helper'
require 'json'

class Api::V1::GamesControllerTest < ActionController::TestCase
  test "Should create a new game with 2 players" do
    player1 = Player.create(name: "max")
    player2 = Player.create(name: "lena")
    assert_difference 'Game.count' do
      post :create, params: { player_ids: [player1.id, player2.id] }
    end
    assert_response :success
    assert_equal ["lena", "max"], Game.last.players.pluck(:name).sort
  end

  test "Should not create a game without 2 players" do
    assert_no_difference 'Game.count' do
      post :create
    end
    assert_response :unprocessable_entity

    player1 = Player.create(name: "max")
    assert_no_difference 'Game.count' do
      post :create, params: { player_ids: [player1.id] }
    end
    assert_response :unprocessable_entity
  end
end
