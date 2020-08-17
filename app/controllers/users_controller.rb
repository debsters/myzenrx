class UsersController < ApplicationController
  
  get '/list/:id' do
    @user = User.find_by(id: params[:id])
    if logged_in?
      if @user.id == current_user.id
        @database_currently_taking_user_medications = Medication.joins(:user_medications).where('user_medications.user_id' => current_user.id, 'user_medications.currently_taking' => 1, 'medications.source' => ['FDA', 'Multum'])
        @database_deactivated_user_medications = Medication.joins(:user_medications).where('user_medications.user_id' => current_user.id, 'user_medications.currently_taking' => 2, 'medications.source' => ['FDA', 'Multum'])
        @currently_taking_user_medications = Medication.joins(:user_medications).where('user_medications.user_id' => current_user.id, 'user_medications.currently_taking' => 1).where.not('medications.source' => ['FDA', 'Multum'])
        @deactivated_user_medications = Medication.joins(:user_medications).where('user_medications.user_id' => current_user.id, 'user_medications.currently_taking' => 2).where.not('medications.source' => ['FDA', 'Multum'])
        erb :'/users/show'
      else
        redirect '/medications'
      end
    else
      redirect '/login'
    end
  end

end