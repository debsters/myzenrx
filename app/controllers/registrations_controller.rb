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

end