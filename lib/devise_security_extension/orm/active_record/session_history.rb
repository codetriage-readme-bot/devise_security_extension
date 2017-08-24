module Devise
  class SessionHistory < Devise.parent_model.constantize
    self.table_name = :devise_session_histories

    belongs_to :session_traceable, polymorphic: true, required: true

    with_options presence: true do
      validates :unique_auth_token_id, uniqueness: true
      validates :ip_address, :user_agent, :last_accessed_at
    end
  end
end
