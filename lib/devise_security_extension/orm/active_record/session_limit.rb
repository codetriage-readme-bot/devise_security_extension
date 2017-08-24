module Devise
  class SessionLimit < Devise.parent_model.constantize
    self.table_name = :devise_session_limits

    belongs_to :session_limitable, polymorphic: true, inverse_of: :session_limits, required: true

    with_options presence: true do
      validates :unique_session_id, uniqueness: true
      validates :last_accessed_at
    end
  end
end
