# Each time a record is fetched from session we check when current session IP address is still
# valid.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  scope = options[:scope]
  session = warden.session(options[:scope])
  env = warden.request.env

  # Skip when current authenticated user isn't authenticated using
  # `ip_authenticable` strategy.
  if session['ip_authentication'] && record.respond_to?(:valid_for_ip_authentication?) &&
     warden.authenticated?(scope) &&
     options[:store] != false &&
     !env['devise.skip_ip_authentication']
    unless record.valid_for_ip_authentication?(warden.request.remote_ip)
      warden.logout(scope)
      throw :warden, scope: scope, message: :unauthenticated
    end
  end
end

# Before each sign out, we remove ip authentication tag in the session.
Warden::Manager.before_logout do |record, warden, options|
  session = warden.request.session["warden.user.#{options[:scope]}.session"]
  if record && record.respond_to?(:valid_for_ip_authentication?) && session
    session.delete('ip_authentication')
  end
end
