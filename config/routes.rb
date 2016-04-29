Rails.application.routes.draw do
  root 'static_pages#home'
  get 'contact' => 'static_pages#contact'
  get 'about' => 'static_pages#about'
  get 'questions' => 'static_pages#questions'
  get 'career' => 'static_pages#career'

######User System#######
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  get 'signup' => 'users#new'
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :users, except: [:new, :show, :destroy] do
    resources :orders, only: [:index]
  end

  resources :shoppers, only: [] do
    resources :orderables, only: [:create]
    resources :orders, only: [:create]
    get 'cart' => 'orderables#index'
    get 'checkout' => 'orders#new'
  end

  resources :orderables, only: [:update, :destroy]
  resources :orders, only: [:show, :update]
  
######Menu System#####
  get 'milktea_orderables/new/:milktea_id' => 'milktea_orderables#new', as: :new_milktea_orderable
  resources :milktea_orderables, only: [:create, :edit, :update]

  get 'menu' => 'recipes#index'
  resources :recipes, only: [:create, :show, :edit, :update] do 
    get 'manage', on: :collection
  end

  resources :dish_categories, only: [:create, :edit, :update]
  resources :milktea_addons, only: [:create, :edit, :update]

######Delivery System#####
  resources :pickup_locations, only: [:index, :create, :show, :edit, :update, :destroy] do
    resources :locations_times, only: [:create]  
    resources :orders, only: [:new, :create]
  end

  resources :pickup_times, only: [:create, :edit, :update, :destroy]

  get 'schedule' => 'locations_times#schedule'
  resources :locations_times, only: [:destroy] do
    resources :orders, only: [:new, :create]
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
