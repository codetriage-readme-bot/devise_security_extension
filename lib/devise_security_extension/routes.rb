module ActionDispatch::Routing
  class Mapper
    protected

    # route for handle expired passwords
    def devise_password_expired(mapping, controllers)
      resource :password_expired, only: %i(show update), path: mapping.path_names[:password_expired],
                                  controller: controllers[:password_expired]
    end

    # route for handle ip authentication
    def devise_ip_authentications(mapping, controllers)
      resource :ip_authentication, only: %i(show), path: mapping.path_names[:ip_auth],
                                   controller: controllers[:ip_authentications]
    end
  end
end
