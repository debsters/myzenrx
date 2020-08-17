class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.timestamp :date_time
      t.string    :med_time
      t.string    :dose_form
      t.string    :dose_strength
      t.integer   :dose_interval
      t.integer   :mood
      t.integer   :energy_level
      t.string    :food_ate
      t.string    :med_take_effect
      t.string    :med_took_effect
      t.string    :med_stopped_time
      t.string    :med_lasted
      t.string    :content
      t.integer   :user_id 
      t.integer   :user_medication_id
    end
  end
end
