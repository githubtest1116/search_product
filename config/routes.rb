Rails.application.routes.draw do
  #トップページ
  root to: 'toppages#index'
  
  #ユーザ登録関連
  #ユーザ編集、削除関連は別途作成する。
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  #ログイン/ログアウト関連
  get 'signup', to: 'users#new'


  #root to: 'items#new'
  #get 'items/new'
  resources :items, only:[:new, :show, :create]
  resources :users, only:[:show, :new, :create, :edit, :update, :destroy]
  resources :ownerships, only: [:create, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
