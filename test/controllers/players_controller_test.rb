require 'test_helper'
require 'json'

class Api::V1::PlayersControllerTest < ActionController::TestCase
  test "Should create a new player" do
    assert_difference 'Player.count' do
      post :create, params: { name: "joe" }
    end
    assert_response :success
    jdata = JSON.parse response.body
    assert_equal "joe", jdata['name']
  end

  test "Should not create a new player if a name is taken" do
    player1 = Player.create(name: "max")
    player2 = Player.create(name: "lena")
    assert_no_difference 'Player.count' do
      post :create, params: { name: "max" }
    end
    assert_response :unprocessable_entity
  end
end
