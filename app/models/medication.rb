class Medication < ActiveRecord::Base
  belongs_to :index
  has_many :user_medications
  has_many :users, through: :user_medications
  
  has_many :entries, through: :user_medications
  validates_presence_of :source, :name, :index_id
end