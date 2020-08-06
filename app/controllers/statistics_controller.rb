class StatisticsController < ApplicationController

  get '/statistics' do
    if logged_in?
      @user = current_user
      @entries = Entry.where(user_id: current_user.id).sort_by { |entry| entry.date_time }
      @data = @entries.group_by{ |t| t.date_time.month}
      erb :'/statistics/statistics'
    else
        redirect '/login'
    end
  end 

 
  
end