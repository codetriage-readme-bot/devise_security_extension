require 'devise_security_extension/hooks/ip_authenticatable'
require 'devise_security_extension/strategies/ip_authenticatable'

module Devise
  module Models
    module IpAuthenticatable
      extend ActiveSupport::Concern

      included do
        has_many :authenticatable_ips, as: :owner, class_name: authenticatable_ip_class.constantize,
                                       dependent: :destroy
      end

      def self.required_fields(_klass)
        [:authenticatable_ip_class]
      end

      def ip_unauthenticated_message
        :invalid
      end

      def active_for_ip_authentication?
        true
      end

      def valid_for_ip_authentication?(ip_address)
        authenticatable_ips.where(ip_address: ip_address).exists?
      end

      # A callback initiated after successfully authenticating. This can be
      # used to insert your own logic that is only run after the user successfully
      # authenticates.
      #
      # Example:
      #
      #   def after_ip_authentication(remote_ip)
      #     self.update_attribute(:invite_code, nil)
      #   end
      #
      def after_ip_authentication(_remote_ip); end

      module ClassMethods
        ::Devise::Models.config self, :authenticatable_ip_class

        def find_for_ip_authentication(conditions, ip_address)
          resource = to_adapter.find_first(conditions)
          opts = { owner: resource, ip_address: ip_address }
          record = resource && authenticatable_ip_class.constantize.to_adapter.find_first(opts)
          record.try(:owner)
        end
      end
    end
  end
end
