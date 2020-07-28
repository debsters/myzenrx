class User < ActiveRecord::Base
  has_secure_password
  validates :email, :presence => true
  has_many :user_medications
  has_many :medications, through: :user_medications
  has_many :entries
end