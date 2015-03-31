class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :session_traceable
end
