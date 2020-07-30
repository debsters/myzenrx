class StatisticsController < ApplicationController

  get '/statistics' do
    if logged_in?
      @user = current_user
      @entries = Entry.where(user_id: current_user.id)
        erb :'/statistics/statistics'
    else
        redirect '/login'
    end
  end 

 
  
end