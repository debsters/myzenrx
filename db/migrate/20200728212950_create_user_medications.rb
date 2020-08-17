class CreateUserMedications < ActiveRecord::Migration
  def change
    create_table :user_medications do |t|
      t.integer :user_id 
      t.integer :medication_id
      t.integer :currently_taking
    end
  end
end
