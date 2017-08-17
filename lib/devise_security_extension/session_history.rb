module DeviseSecurityExtension
  class SessionHistory < Devise.parent_model.constantize
    self.table_name = 'devise_session_histories'

    belongs_to :session_traceable, polymorphic: true
  end
end
