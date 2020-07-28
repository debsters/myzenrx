class MedicationsController < ApplicationController
  get '/medications' do
		if logged_in?
			@indices = Index.all
			erb :'/medications/index'
		else
			redirect '/login'
		end
	end
	
  get '/medications/:id' do
		if logged_in?
			@user = current_user
			@medication = Medication.find_by(id: params[:id])
			@user_medication = UserMedication.find_by(user_id: current_user.id, medication_id: @medication.id)
			erb :'/medications/show'
		else
				redirect '/login'
		end
  end

  post '/medications/:id' do
		@medication = Medication.find_by(id: params[:user_medication][:medication_id])
		@user = User.find_by(id: params[:user_medication][:user_id])
		if logged_in?
      if @user.id == current_user.id
        UserMedication.where(user_id: @user.id, medication_id: @medication.id, active: 1).first_or_create
        redirect "/medications/#{@medication.id}"
      else
        redirect "/medications"
      end
		else
			redirect '/login'
		end
	end

	post '/medications' do
		if logged_in?
			@user = current_user
			user_med = UserMedication.new(active: 1)
			new_med = user_med.create_medication(name: params["medication"]["name"], source: "user_id: #{current_user.id}", index_id: "#{params["medication"]["name"]}".initial.to_number)
			new_med.save
			user_med.user = current_user
			user_med.save
			redirect "/list/#{current_user.id}"
		else
			redirect '/login'
		end
	end
	

	patch '/medications/:id' do
		@medication = Medication.find_by(id: params[:id])
		@user_medication = UserMedication.find_by(user_id: current_user.id, medication_id: @medication.id)
		if logged_in?
			@user_medication.update(params[:user_medication])
			redirect "/medications/#{@medication.id}"
		else
			redirect '/login'
		end
	end


  delete '/medications/:id' do
		@medication = Medication.find_by(id: params[:user_medication][:medication_id])
		@user = User.find_by(id: params[:user_medication][:user_id])
		if logged_in?
			if @user.id == current_user.id
				user_medication = UserMedication.find_by(user_id: @user.id, medication_id: @medication.id)
				user_medication.delete
					redirect "/list/#{@user.id}"
			else
					redirect '/medications'
			end
		else
				redirect '/login'
		end
	end

end