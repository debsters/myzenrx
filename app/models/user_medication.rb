class UserMedication < ActiveRecord::Base 
  belongs_to :user 
  belongs_to :medication
  has_many :entries
  validates_presence_of :user_id, :medication_id, :currently_taking
end 