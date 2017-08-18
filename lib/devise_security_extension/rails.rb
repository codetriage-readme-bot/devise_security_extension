require 'recaptcha/rails'

module DeviseSecurityExtension
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseSecurityExtension::Controllers::Helpers
    end

    def self.activate
      DeviseSecurityExtension::Patches.apply
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
