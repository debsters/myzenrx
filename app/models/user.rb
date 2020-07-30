class User < ActiveRecord::Base
  has_secure_password
  has_many :user_medications
  has_many :medications, through: :user_medications
  has_many :entries

  validates :email, :presence => true
  validates :username, uniqueness: true, presence: true
  validates :password, presence: true
  validates :password, confirmation: {case_sensitive: true}
end