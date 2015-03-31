class CreateTables < ActiveRecord::Migration
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

      t.references :password_archivable, polymorphic: true
    end

    create_table :devise_session_histories do |t|
      t.text :unique_auth_token_id, null: false
      t.string :ip_address
      t.string :user_agent
      t.time :last_accessed_at
      t.boolean :unique_auth_token_valid, default: true

      t.references :session_traceable, polymorphic: true
    end
  end

  def self.down
    drop_table :users
    drop_table :old_passwords
  end
end
