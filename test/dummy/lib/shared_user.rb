module SharedUser
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable, :session_traceable, :session_limitable, :timeoutable,
           :password_archivable
  end
end
