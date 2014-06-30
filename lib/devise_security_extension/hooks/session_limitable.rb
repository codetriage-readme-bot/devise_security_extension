# After each sign in, update unique_session_id.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication. Retrieving the user from session (:fetch) does
# not trigger it.
Warden::Manager.after_set_user :except => :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:archive_unique_session!) && warden.authenticated?(options[:scope])
    unique_session = record.archive_unique_session!
    if unique_session
      warden.session(options[:scope])['unique_session_id'] = unique_session
    else
      warden.logout(scope)
      throw :warden, :scope => scope, :message => :session_limited
    end
  end
end

# Each time a record is fetched from session we check if a new session from another
# browser was opened for the record or not, based on a unique session identifier.
# If so, the old account is logged out and redirected to the sign in page on the next request.
Warden::Manager.after_set_user :only => :fetch do |record, warden, options|
  scope = options[:scope]
  session =  warden.request.session["warden.user.#{scope}.session"]
  if record.respond_to?(:accept_unique_session?) && warden.authenticated?(scope) && options[:store] != false && session['unique_session_id'].present?
    if record.accept_unique_session?(session['unique_session_id'])
      record.update_last_request_at(session['unique_session_id'])
    else
      warden.logout(scope)
      throw :warden, :scope => scope, :message => :session_limited
    end
  end
end

# Destroy session
Warden::Manager.before_logout do |record, warden, options|
  session =  warden.request.session["warden.user.#{options[:scope]}.session"]
  if record.respond_to?(:un_archive_unique_session) && session.present? && session['unique_session_id'].present?
    record.un_archive_unique_session(session['unique_session_id'])
    session.delete 'unique_session_id'
  end
end
