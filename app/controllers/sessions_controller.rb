class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash[:danger] = 'Invalid email/password combination'
      # Create an error message.
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def omniauth #log users in with omniauth
    user  = User.find_or_create_by(email: auth[:info][:email]) do |u|
          u.email = auth[:info][:email]
          u.name = auth[:info][:name]
          u.uid = auth[:uid]
          u.provider = auth[:provider]
          u.password = SecureRandom.hex(10)
    end

    if user.valid?
        session[:user_id] = user.id;
        log_in user
        redirect_back_or user
    else
      flash[:message] = 'Credential error'
      redirect_to login_path
    end
  end
  
  private 
  def auth
    request.env['omniauth.auth']
  end

end

