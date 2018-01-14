Rails.application.routes.draw do
  #トップページ
  root to: 'toppages#index'
  
  #ユーザ登録関連
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  #ログイン/ログアウト関連
  get 'signup', to: 'users#new'

  #ユーザ詳細　追加情報関連
  get 'users/help', to: 'users#help', as: 'help'
  get 'items/register', to:'items#item_register_url', as: 'item_register_url'
  post 'items/register', to:'items#item_register_info', as: 'item_register_info'
  
  resources :items, only:[:new, :show, :create]
  resources :users, only:[:show, :new, :create, :edit, :update, :destroy]
  resources :ownerships, only: [:create, :destroy]
  
  post 'users/:id', to: 'items#bulk_create', as: 'bulk_create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
