require 'devise_security_extension/hooks/session_limitable'

module Devise
  module Models
    # SessionLimited ensures, that there is only one session usable per account at once.
    # If someone logs in, and some other is logging in with the same credentials,
    # the session from the first one is invalidated and not usable anymore.
    # The first one is redirected to the sign page with a message, telling that 
    # someone used his credentials to sign in.
    module SessionLimitable
      extend ActiveSupport::Concern

      included do
        has_many :devise_sessions, :as => :session_limitable, :dependent => :destroy
      end

      def un_archive_unique_session(unique_session_id)
        find_unique_session_id(unique_session_id).try :delete
      end

      def archive_unique_session!
        archive_unique_session if allow_create_session?
      end

      def update_last_request_at(unique_session_id)
        find_unique_session_id(unique_session_id).update_attributes(:last_request_at => Time.now)
      end

      def find_unique_session_id(unique_session_id)
        self.devise_sessions.find :first, :conditions => {:unique_session_id =>unique_session_id}
      end
      alias_method :accept_unique_session?, :find_unique_session_id

      private
      def generate_unique_session
        loop do
          token = Devise.friendly_token
          break token unless accept_unique_session?(token)
        end
      end

      def archive_unique_session
        devise_session = self.devise_sessions.new(:unique_session_id => generate_unique_session, :last_request_at => Time.now)
        devise_session.save ? devise_session.unique_session_id : false
      end

      def allow_create_session?
        !sessions_on_limit? || (!reject_session_on_limit? && create_session_space!) || sessions_allowed_count == 0
      end

      def create_session_space!
        reject_session_on_limit? ? self.devise_sessions.where('last_request_at <= ?', (Time.now - session_expiration)).destroy_all : self.devise_sessions.order(:id).reverse_order.offset(sessions_allowed_count).delete_all
      end

      def reject_session_on_limit?
        self.respond_to?(:sessions_reject_on_limit) && self.sessions_reject_on_limit.present? ? self.sessions_reject_on_limit : self.class.default_sessions_reject_on_limit
      end

      def sessions_on_limit?
        self.devise_sessions.count >= sessions_allowed_count
      end

      def sessions_allowed_count
        self.respond_to?(:sessions_count_limit) && self.sessions_count_limit.present? ? self.sessions_count_limit : self.class.default_sessions_limit
      end

      def session_expiration
        self.respond_to?(:sessions_expiration) && self.sessions_expiration.present? ? self.sessions_expiration : self.class.default_sessions_expiration
      end

      module ClassMethods
        ::Devise::Models.config(self, :default_sessions_limit, :default_sessions_reject_on_limit, :default_sessions_expiration)
      end
    end
  end
end