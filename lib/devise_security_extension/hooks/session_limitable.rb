# After each sign in, update unique_session_id.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication. Retrieving the user from session (:fetch) does
# not trigger it.
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:log_limitable_request!) && warden.authenticated?(scope)
    unique_session_id = record.log_limitable_request!
    if unique_session_id
      warden.session(scope)['unique_session_id'] = unique_session_id
    else
      warden.logout(scope)
      throw :warden, scope: scope, message: :session_limited
    end
  end
end

# Each time a record is fetched from session we check if a new session from another
# browser was opened for the record or not, based on a unique session identifier.
# If so, the old account is logged out and redirected to the sign in page on the next request.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  scope = options[:scope]
  session = warden.session(options[:scope])
  env = warden.request.env
  if record.respond_to?(:accept_limitable_token?) && warden.authenticated?(scope) &&
     options[:store] != false &&
     !env['devise.skip_session_limitable']
    if session['unique_session_id'].present? && record.accept_limitable_token?(session['unique_session_id'])
      record.update_limitable_access_at(session['unique_session_id'])
    else
      warden.logout(scope)
      throw :warden, scope: scope, message: :unauthenticated
    end
  end
end

# Before each sign out, we expire the session.
Warden::Manager.before_logout do |record, warden, options|
  session = warden.request.session["warden.user.#{options[:scope]}.session"]
  if record && record.respond_to?(:expire_session_limit) && session && session['unique_session_id'].present?
    record.expire_session_limit(session['unique_session_id'])
    session.delete 'unique_session_id'
  end
end
