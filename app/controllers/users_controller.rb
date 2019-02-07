class UsersController < ApplicationController
  wrap_parameters User, include: [:email, :password]

  def create
    @user = User.new(user_params)
    unless @user.save
      render status: 400
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

end
