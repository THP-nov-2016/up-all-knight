Rails.application.routes.draw do

  devise_for :players, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  root 'static_pages#index'
  get 'about', to: "static_pages#about"
  match 'ranking', to: "static_pages#ranking", via: :get
  resources :games do
    resources :pieces, only: :update
    resources :pieces do
      match "promote_pawn", to: "pieces#promote_pawn", via: :put
    end
    patch 'add_player', on: :member
    match 'draw', to: "games#draw", via: :put
    match 'reject_draw', to: "games#reject_draw", via: :put
    match 'forfeit', to: "games#forfeit", via: :put
  end
  
  resources :pusher do
    post 'auth', on: :collection
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
