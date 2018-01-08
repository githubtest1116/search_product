class UsersController < ApplicationController
  before_action :set_params, only: [:show, :edit, :update, :destroy]
  before_action :require_user_logged_in, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = 'ユーザを登録しました。'
      
      #セッション情報を設定
      session[:user_id] = @user.id
      
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザの登録に失敗しました。'
      render :new
    end
  end

  def show
    #before_action
    @items = @user.ownership_items.page(params[:page]).per(5)
  end
  
  def edit
    #before_action
  end
  
  def update
    #before_action

    if @user.update(user_params) && params[:user][:password] != "" && params[:user][:password_confirmation] != ""
      flash[:success] = "登録情報を更新しました"
      redirect_to @user
    else
      flash.now[:danger] = "登録情報の更新が出来ませんでした"
      render :edit
    end
  end
  
  def destroy
    #before_action
    
    @user.destroy
    
    flash[:success] = "登録情報を削除しました"
    session[:user_id] = nil
    redirect_to root_url
  end
  
  def help
    render :layout => 'help_layout'
  end

  private

  def set_params
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
