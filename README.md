# Battleship game API

API for the classic [battleship game](https://en.wikipedia.org/wiki/Battleship_(game))

## What does it provide:
* `POST /users {name: John}` will create a user. Presence of name is validated.
* `POST /games {player_ids: [1,2]}` will create a game. Validates presence of 2 players,
  sets game state to `init`
* `POST /games/:id/add_board {player_id: 1, set_ships: {carrier: ["a1", "a2", "a3", "a4", "a5"], battleship: [...], cruiser: [...], destroyer1: [...], destroyers2[...], submarine1: [...], submarine2: [...]]}}` will create a two-dimensional array where each array represents a row with 10 elements (which by index represent the row-column value) and sets type of ship to corresponding element.
  Validates if all types of ships of a proper size were provided; only players specified when creating a game can add board to the game.
* `POST /games/:id/start` starts a game setting it's state to `on` and returning player name whose turn is the first one. Validates if the game exists, if it has been already started and if both players have boards set up for a game.
* `POST /games/:id/make_turn {player_id: 1, cell: "a1"}` which will set the cell value to either `hit` or `miss` and increment score of a current player, set the next turn player id to the game, change it's state to `over` if player hit the last cell, render message which kind of cell has been hit or encouraging 'Try guessing harder' message. Other player cannot make two turns one after another as the game keeps the state who is next.
* `GET /games/:id/score` returns the current game state and the scores of both players i.e. `{ state: over, current_score: [["Michi", 1, 10], ["Clara", 2, 15]] }`
* `GET /leaderboard` returns ordered by games won list of players with names and players ids i.e. `[{"name"=>"Clara", "games_won"=>2}, {"name"=>"Michi", "games_won"=>1}]`

##Ruby / Rails
```
ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-darwin15]
Rails 5.0.1
```
##Run the tests
```
git clone git@github.com:entropyftw/battleship_api.git
cd battleship_api
rails db:create db:migrate db:fixtures:load
ruby -I lib:test (or rails test etc.) test/controllers/games_controller_test.rb
ruby -I lib:test (or rails test etc.) test/controllers/players_controller_test.rb
or start a server with `rails s` and test it with `curl`
```
##TODO
```
A lof of room for improvements.
- Validate coordinates when making a turn
- Better check for params to set up boards
- Move Board relevant code from Games controller to the Board class
- Write more tests for sabotge
- Hadle params Rails 5.1 way instead of converting them to hash to call all
  fancy methods
- There is much more. Stay tuned.
```
