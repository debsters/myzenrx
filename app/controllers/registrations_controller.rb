class RegistrationsController < ApplicationController

  get '/signup' do
    erb :'/registrations/signup'
  end

  post '/registrations' do
    @user = User.new(params[:user])
    if @user.save
      redirect '/login'
    else
      erb :'/registrations/signup'
    end
  end

  get '/registrations/:id/edit' do
    @user = User.find_by(id: params[:id])
    if logged_in?
      # Make sure the user exists in the current user is trying to edit their own info
      if @user && @user.id == current_user.id
        erb :'/users/edit'
      end
    else
      redirect '/login'
    end
  end
  
  patch '/registrations/:id' do
    @user = User.find_by(id: params[:id])
    if logged_in?
      @user.update(params[:user])
      redirect "/entries"
    else 
      redirect '/login'
    end 
  end
  

end