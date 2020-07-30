class StatisticsController < ApplicationController

  get '/statistics' do
    @user = current_user
    if logged_in?
        erb :'/statistics/statistics'
    else
        redirect '/login'
    end
  end 

 
  
end