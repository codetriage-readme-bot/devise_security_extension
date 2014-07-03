class DeviseSession < ActiveRecord::Base
  belongs_to :session_limitable, :polymorphic => true
end
