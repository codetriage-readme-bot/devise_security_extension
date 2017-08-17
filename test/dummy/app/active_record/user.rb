require 'shared_user'

class User < Devise.parent_model.constantize
  include Shim
  include SharedUser
end
