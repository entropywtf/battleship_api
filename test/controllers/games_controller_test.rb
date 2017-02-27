require 'test_helper'
require 'json'

class Api::V1::GamesControllerTest < ActionController::TestCase
  test "Should create a new game with 2 players" do
    assert_difference 'Game.count' do
      post :create, params: { player_ids: [1, 2] }
    end
    assert_response :success
    assert_equal ["Clara", "Michi"], Game.last.players.pluck(:name).sort
  end

  test "Should not create a game if no player provided" do
    assert_no_difference 'Game.count' do
      post :create
    end
    assert_response :unprocessable_entity
  end

  test "Should not create a game if only 1 player provided" do
    assert_no_difference 'Game.count' do
      post :create, params: { player_ids: [1] }
    end
    assert_response :unprocessable_entity
  end

  test "Should not create a game if not more than 2 players provided" do
    assert_no_difference 'Game.count' do
      post :create, params: { player_ids: [1, 2, 3] }
    end
    assert_response :unprocessable_entity
  end

  test "Should render a finished game score" do
    get :score, params: { id: 1 }

    assert_response :success
    jdata = JSON.parse response.body
    assert jdata["is_over"]
    assert_equal jdata["score"], [["Michi", 1, 15], ["Clara", 2, 9]]
  end

  test "Should render an unfinished game score" do
    get :score, params: { id: 4 }

    assert_response :success
    jdata = JSON.parse response.body
    refute jdata["is_over"]
    assert_equal jdata["score"], [["Michi", 1, 5], ["Clara", 2, 6]]
  end

  test "Should render a leaderboard" do
    get :leaderboard

    assert_response :success
    jdata = JSON.parse response.body
    assert_equal [{"name"=>"Clara", "games_won"=>2}, {"name"=>"Michi",
      "games_won"=>1}], jdata
  end

  test "Should add a board" do
    post :add_board, params: { id: 1, player_id: 1,
      set_ships: {
        carrier: ["a1", "a2", "a3", "a4", "a5"],
        battleship: ["e8", "f8", "g8", "h8"],
        cruiser: ["g3", "g4", "g5"],
        destroyer1: ["e4", "e5"],
        destroyer2: ["b2", "c2"],
        submarine1: ["i2"],
        submarine2: ["c4"]
      }
    }
    assert_response :success
    b = Board.first
    assert_equal b.grid[0][2], "carrier"
  end

  test "Should start a game" do
    post :start_game, params: { id: 5 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/Game started. Next turn:/, jdata["message"])
    assert_equal Game.find(5).state, "on"
  end

  test "Should not start non-existent game" do
    post :start_game, params: { id: 666 }
    jdata = JSON.parse response.body
    assert_equal "not_found", jdata["status"]
  end

  test "Should not start already started game" do
    post :start_game, params: { id: 1 }
    jdata = JSON.parse response.body
    assert_equal "unprocessable_entity", jdata["status"]
    assert_match(/This game has been already started./,
      jdata["message"])
  end

  test "Should pause a game" do
    post :pause_game, params: { id: 1 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/Game paused./, jdata["message"])
    assert_equal Game.find(1).state, "paused"

  end

  test "Should resume a game" do
    post :resume_game, params: { id: 1 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/Game resumed. Next turn:/, jdata["message"])
    assert_equal Game.find(1).state, "on"
  end
end
