require 'time'
require 'pry'
class EntriesController < ApplicationController

  get '/entries' do
    if logged_in?
      @user = current_user
      @entries = @user.entries.sort_by { |entry| entry.date_time }
      @user_medications = UserMedication.where(user_id: current_user.id)
      erb :'/entries/entries'
    else
      redirect '/login'
    end
  end 

  get '/entries/new' do
    if logged_in?
      @user = current_user
      @user_medications = UserMedication.where(user_id: current_user.id)
      @medications = Medication.joins(:user_medications).where('user_medications.user_id' => current_user)
      erb :'/entries/create_entry'
    else
      redirect '/login'
    end
  end 

  post '/entries' do
    view_mode_input(params[:entry])
 
    if !((params[:entry]["med_took_effect"].empty?) && (params[:entry]["med_stopped_time"].empty?))
      start_time = Time.parse(params[:entry]["med_took_effect"]).strftime("%H:%M")
      finish_time = Time.parse(params[:entry]["med_stopped_time"]).strftime("%H:%M")
      params[:entry]["med_lasted"] = time_elapsed(start_time, finish_time)
    end
    
    if params[:entry]["user_medication_id"].empty?
      if !params["medication"]["name"].empty?
        user_med = UserMedication.new(active: 1)
        new_med = user_med.create_medication(name: params["medication"]["name"], source: "user_id: #{current_user.id}", index_id: "#{params["medication"]["name"]}".initial.to_number)
        new_med.save
        user_med.user = current_user
        user_med.save
        params[:entry]["user_medication_id"] = "#{user_med.id}"
      else
        params[:entry]["user_medication_id"] = ""
      end
    end
    
    @entry = current_user.entries.build(params[:entry])
   
    if @entry.valid?
      @entry.save
      redirect '/entries'
    else
      flash[:entry_error] = fix_entry_error_messages_array(@entry.errors.full_messages)
      redirect '/entries/new'
    end

  end

  get '/entries/:id' do
    @entry = Entry.find_by(id: params[:id])
    if logged_in? 
      if (@entry != nil) && (@entry.user_id == current_user.id)
        @user = current_user
        @user_medications = UserMedication.where(user_id: current_user.id)
        erb :'/entries/entry'
      else
        redirect '/entries'
      end
    else
      redirect '/login'
    end
  end

  get '/entries/:id/edit' do
    @entry = Entry.find_by(id: params[:id])
    if logged_in?
      if (@entry != nil) && (@entry.user_id == current_user.id)
        @user = current_user
        @user_medications = UserMedication.where(user_id: current_user.id)
        @medications = Medication.joins(:user_medications).where('user_medications.user_id' => current_user)
        erb :'entries/edit'
      else
        redirect '/entries'
      end
    else
      redirect '/login'
    end
  end

  patch '/entries/:id' do
    @entry = Entry.find_by_id(params[:id]) 
    view_mode_input(params[:entry])

    if !((params[:entry]["med_took_effect"].empty?) && (params[:entry]["med_stopped_time"].empty?))
      start_time = Time.parse(params[:entry]["med_took_effect"]).strftime("%H:%M")
      finish_time = Time.parse(params[:entry]["med_stopped_time"]).strftime("%H:%M")
      params[:entry]["med_lasted"] = time_elapsed(start_time, finish_time)
    end
    
    if params[:entry]["user_medication_id"].empty?
      if !params["medication"]["name"].empty?
        user_med = UserMedication.new(active: 1)
        new_med = user_med.create_medication(name: params["medication"]["name"], source: "user_id: #{current_user.id}", index_id: "#{params["medication"]["name"]}".initial.to_number)
        new_med.save
        user_med.user = current_user
        user_med.save
        params[:entry]["user_medication_id"] = "#{user_med.id}"
      else
        params[:entry]["user_medication_id"] = ""
      end
    end
    
    @entry.update(params[:entry])

    if @entry.valid?
      redirect "/entries/#{@entry.id}"
    else
      flash[:entry_error] = fix_entry_error_messages_array(@entry.errors.full_messages)
      redirect "/entries/#{@entry.id}/edit"
    end
  end

  delete '/entries/:id' do
    @entry = Entry.find_by_id(params[:id])
    @entry.delete
    redirect '/entries'
  end

end



