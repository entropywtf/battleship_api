Rails.application.routes.draw do
  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :players
      resources :games do
        member do
          get 'score'
          post 'add_board'
          post 'start_game'
          post 'pause_game'
          post 'resume_game'
          post 'make_turn'
        end
        collection do
          get 'leaderboard'
        end
        resources :boards
      end
    end
  end
end
