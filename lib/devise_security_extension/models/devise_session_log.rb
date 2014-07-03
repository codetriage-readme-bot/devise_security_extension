class DeviseSessionLog < ActiveRecord::Base
  belongs_to :session_loggable, :polymorphic => true
end
