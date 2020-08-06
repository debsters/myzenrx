require './config/environment'
require 'sinatra/flash'
require './config/initializers/chartkick.rb'

class ApplicationController < Sinatra::Base
 #==================== CONFIGURATION =======================
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    register Sinatra::Flash
    enable :sessions
    set :session_secret, "myzenrxapp"
  end

  #----------------------------------------------------------

   #==================== INDEX ===================
   get '/' do
    if logged_in? 
      redirect '/entries'
    else 
      erb :'sessions/login'
    end 
  end
  
  #----------------------------------------------------------

  #==================== HELPERS =============================
  helpers do

    MINUTES_PER_DAY = 24*60

    def time_elapsed(start_str, finish_str)
      start_mins = time_str_to_minutes(start_str)  
      finish_mins = time_str_to_minutes(finish_str)
      finish_mins += MINUTES_PER_DAY if
        finish_mins < start_mins
      (finish_mins-start_mins).divmod(60)
    end

    def time_str_to_minutes(str)
      hrs, mins = str.split(':').map(&:to_i)
      60 * hrs + mins
    end

    def elapsed(string)
      array = JSON.parse(string)
      "#{array[0]} Hours #{array[1]} Minutes"
    end

    def view_mode_input(params_hash)
      params_hash.each do |entry_name, entry_input|
        if entry_input.is_a?(Hash)
          new_entry_input = entry_input.delete_if { |key, value| value.blank? }.values.join
          params_hash[entry_name] = new_entry_input
          if params_hash[entry_name].match? (/(\/)/) 
            params_hash[entry_name] = DateTime.strptime(new_entry_input, '%m/%d/%Y %l:%M %p')
          end
        end
      end
    end

    def fix_entry_error_messages_array(array)
      array.map do |string|
        new_array = string.split(/(can't be blank)/)
        new_array[0] = new_array[0].split.map(&:capitalize).join(' ')
        string = new_array.join(' ').gsub("User Medication", "Medication Name").gsub("Date Time", "Entry Date and Time").gsub("Mood", "Mood Level").gsub("Content", "Entry Notes").gsub("Food Ate", "Ate Food")
      end
    end

    def mobile_device?
      if session[:mobile_param]
        session[:mobile_param] == "1"
      else
        request.user_agent =~ /Mobile|webOS/
      end
    end

    def mood_icon(mood)
      if mood == "1"
        "<img class='emoji' src='/stylesheets/images/mood/1.Amazing.png' alt='ZenRx Amazing Mood'/>"
      elsif mood == "2"
        "<img class='emoji' src='/stylesheets/images/mood/2.Happy.png' alt='ZenRx Happy Mood'/>"
      elsif mood == "3"
        "<img class='emoji' src='/stylesheets/images/mood/3.Normal.png' alt='ZenRx Normal Mood'/>"
      elsif mood == "4"
        "<img class='emoji' src='/stylesheets/images/mood/4.Horrible.png' alt='ZenRx Sad Mood'/>"
      elsif mood == "5"
        "<img class='emoji' src='/stylesheets/images/mood/5.Awful.png' alt='ZenRx Awful Mood'/>"
      else
        "Not able to read mood level"
      end
    end

    def energy_icon(energy)
      if energy == 1
        "<img class='battery' src='/stylesheets/images/energy/1.VeryLow.png' alt='ZenRx Very Low Energy'/>"
      elsif energy == 2
        "<img class='battery' src='/stylesheets/images/energy/2.Low.png' alt='ZenRx Low Energy'/>"
      elsif energy == 3
        "<img class='battery' src='/stylesheets/images/energy/3.NormalYellow.png' alt='ZenRx Normal Energy'/>"
      elsif energy == 4
        "<img class='battery' src='/stylesheets/images/energy/4.Good.png' alt='ZenRx Good Energy'/>"
      elsif energy == 5
        "<img class='battery' src='/stylesheets/images/energy/5.Great.png' alt='ZenRx Great Energy'/>"
      else
        "Not able to read energy level"
      end
    end

    def medications_under_index(string_index)
      Medication.where(:index_id => "#{string_index}")
    end

    def entry_graph_data(entries)
      array_mood = []
      array_energy = []
      entries.each do |entry| 
        array_mood << ["#{entry.date_time.strftime("%m/%d/%Y %l:%M %p")}", entry.mood.to_i  ] 
        array_energy << ["#{entry.date_time.strftime("%m/%d/%Y %l:%M %p")}", entry.energy_level] 
      end  
      data = [{name: "Mood", data: array_mood }, {name: "Energy", data: array_energy}]
    end

    def logged_in?
      !!current_user
    end

    def current_user
      @current_user ||= User.find_by(:id => session[:user_id]) if session[:user_id]
    end

    def login(username, password)
      user = User.find_by(:username => username)
      if user && user.authenticate(password)
        session[:user_id] = user.id
      else
        redirect '/login'
      end
    end

    def logout!
      session.clear
    end
  end

  #----------------------------------------------------------
  
end