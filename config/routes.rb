Pushpin::Application.routes.draw do
  root to: 'static_pages#home'

  # Static pages 
  match '/help', to: 'static_pages#help', via: 'get'

  # Authentication
  match '/signup',  to: 'users#new',        via: 'get'
  match '/signin',  to: 'sessions#new',     via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  # Email/Pinboard confirmation
  match '/confirm/:type/:code', 
      to: 'users#confirm', via: 'get', as: 'confirm'
  match '/confirm/:type/:code', 
      to: 'users#process_confirmation', via: 'post', as: 'process_confirmation'

  # REST resources
  resources :users do
      member do
          get :following, :followers, :links, :comments
      end
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :comments, only: [:create, :destroy]
  resources :links, only: :show
  resources :links do
      member do
          get :share, :save, :new_comment
      end
  end
  resources :relationships, only: [:create, :destroy]


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root to: 'welcome#index'

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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
