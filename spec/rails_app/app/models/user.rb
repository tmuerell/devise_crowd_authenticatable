class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :crowd_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable# , :validatable
end