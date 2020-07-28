class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_medication
  validates_presence_of :date_time, :med_time, :dose_form, :dose_strength, :dose_interval, :mood, :energy_level, :food_ate, :med_take_effect, :med_took_effect, :med_stopped_time, :med_lasted, :content, :user_id, :user_medication_id
end