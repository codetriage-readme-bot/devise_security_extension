module DeviseSecurityExtension
  class SessionLimit < ActiveRecord::Base
    self.table_name = 'devise_session_limits'

    belongs_to :session_limitable, polymorphic: true
  end
end