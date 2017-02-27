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
    assert_equal "over", jdata["state"]
    assert_equal jdata["score"], [["Michi", 1, 15], ["Clara", 2, 9]]
  end

  test "Should render an unfinished game score" do
    get :score, params: { id: 4 }

    assert_response :success
    jdata = JSON.parse response.body
    refute jdata["is_over"]
    assert_equal jdata["score"], [["Michi", 1, 0], ["Clara", 2, 0]]
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
    b = Board.last
    assert_equal b.grid[0][2], "carrier"
  end

  test "Should not start a game if boards for players are not set up" do
    post :start_game, params: { id: 5 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/Boards are not set up for players./, jdata["message"])
  end

  test "Should start a game" do
    Board.create(game_id: 5, player_id:1)
    Board.create(game_id: 5, player_id:2)
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

  test "Should not make turn if it's not turn of this player" do
    post :make_turn, params: { id: 4, player_id: 1 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/This is not your turn./, jdata["message"])
  end

  test "Should not make turn if game is not yet started and turn_uid defined" do
    g = Game.find(4)
    g.state = "init"
    assert g.save
    post :make_turn, params: { id: 4, player_id: 1 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/Start a game first./, jdata["message"])
  end

  test "Should make turn, hit the ship and get a score" do
    old_score = Score.where(player_id: 2, game_id: 4).first.score
    assert_equal 0, old_score
    post :make_turn, params: { id: 4, player_id: 2, cell: "a1"}
    assert_response :success
    jdata = JSON.parse response.body
    assert_match(/You hit carrier!/, jdata["message"])
    new_score = Score.where(player_id: 2, game_id: 4).first.score
    assert_not_equal old_score, new_score
    assert_equal 1, new_score
  end
end
