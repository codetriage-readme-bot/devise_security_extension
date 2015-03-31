module DeviseSecurityExtension
  class SessionHistory < ActiveRecord::Base
    self.table_name = 'devise_session_histories'

    belongs_to :session_traceable, polymorphic: true
  end
end