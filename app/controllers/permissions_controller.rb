class PermissionsController < ApplicationController
  after_action :verify_authorized, only: [:index, :update]
  skip_after_action :verify_policy_scoped, only: :index

  def index
    @users = User.all
    authorize @users
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update(user_params)
      redirect_to permissions_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user

  end

  def destroy
     @user = User.find(params[:id])
     authorize @user
    if @user.destroy
      redirect_to permissions_path, notice: 'User was successfully deleted.'
    else
      render :show, notice: 'There was problem deleting this item.'
    end
  end

  private

  def user_params
    params.require(:user).permit(:status, :name, :email)
  end
end
