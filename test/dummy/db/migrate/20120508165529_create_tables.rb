# TODO: Inherit from the 5.0 Migration class directly when we drop support for Rails 4.
class CreateTables < (ActiveRecord::Migration.respond_to?(:[]) ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration )
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :facebook_token

      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      t.timestamps(null: false)
    end

    create_table :old_passwords do |t|
      t.string :encrypted_password
      t.string :password_salt

      t.references :password_archivable, polymorphic: true, index: { name: :idx_1 }
    end

    create_table :devise_session_histories do |t|
      t.text :unique_auth_token_id, null: false
      t.string :ip_address
      t.string :user_agent
      t.datetime :last_accessed_at
      t.boolean :unique_auth_token_valid, default: true

      t.references :session_traceable, polymorphic: true, index: { name: :idx_2 }
    end

    create_table :devise_session_limits do |t|
      t.string :unique_session_id, limit: 20
      t.datetime :last_accessed_at

      t.references :session_limitable, polymorphic: true, index: { name: :idx_3 }
    end
  end

  def self.down
    drop_table :users
    drop_table :old_passwords
    drop_table :devise_session_histories
    drop_table :devise_session_limits
  end
end
