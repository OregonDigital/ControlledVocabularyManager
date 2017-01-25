class Admin::UsersController < AdminController
  respond_to :html, :json

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if current_user.id == @user.id
      flash[:error] = "You can't change your own user profile."
    else
      @user.update_attributes(user_params)
    end
    respond_with @user, :location => admin_users_path
  end

  def show
  end

  private 

    def user_params
      params.require(:user).permit(:name, :email, :role, :institution)
    end

end
