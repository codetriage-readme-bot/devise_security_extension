# encoding: UTF-8

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_120_508_165_529) do
  create_table 'devise_session_histories', force: :cascade do |t|
    t.text     'unique_auth_token_id', null: false
    t.string   'ip_address'
    t.string   'user_agent'
    t.datetime 'last_accessed_at'
    t.boolean  'unique_auth_token_valid', default: true
    t.integer  'session_traceable_id'
    t.string   'session_traceable_type'
  end

  create_table 'devise_session_limits', force: :cascade do |t|
    t.string   'unique_session_id', limit: 20
    t.datetime 'last_accessed_at'
    t.integer  'session_limitable_id'
    t.string   'session_limitable_type'
  end

  create_table 'old_passwords', force: :cascade do |t|
    t.string  'encrypted_password'
    t.string  'password_salt'
    t.integer 'password_archivable_id'
    t.string  'password_archivable_type'
  end

  create_table 'users', force: :cascade do |t|
    t.string   'username'
    t.string   'facebook_token'
    t.string   'email',              default: '', null: false
    t.string   'encrypted_password', default: '', null: false
    t.datetime 'created_at',                      null: false
    t.datetime 'updated_at',                      null: false
  end
end
