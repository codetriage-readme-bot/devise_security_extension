
Warden::Manager.after_set_user :except => :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:log_devise_session!) && warden.authenticated?(options[:scope])
    unique_auth_token_id = Devise.friendly_token
    if record.log_devise_session!(warden.request, unique_auth_token_id)
      warden.session(options[:scope])['unique_auth_token_id'] = unique_auth_token_id
    else
      warden.logout(scope)
      throw :warden, :scope => scope, :message => :unauthenticated
    end
  end
end

Warden::Manager.after_set_user :only => :fetch do |record, warden, options|
  scope = options[:scope]
  session =  warden.request.session["warden.user.#{scope}.session"]
  if record.respond_to?(:accept_devise_session_token?) && warden.authenticated?(scope) && options[:store] != false && session['unique_auth_token_id'].present?
    if record.accept_devise_session_token?(warden.request, session['unique_auth_token_id'])
      record.update_last_accessed_at(session['unique_auth_token_id'])
    else
      warden.logout(scope)
      throw :warden, :scope => scope, :message => :unauthenticated
    end
  end
end

Warden::Manager.before_logout do |record, warden, options|
  session =  warden.request.session["warden.user.#{options[:scope]}.session"]
  if record && record.respond_to?(:invalidate_devise_session_log!) && session && session['unique_auth_token_id'].present?
    record.invalidate_devise_session_log!(session['unique_auth_token_id'])
    session.delete 'unique_auth_token_id'
  end
end
