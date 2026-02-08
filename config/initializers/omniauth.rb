Rails.application.config.middleware.use OmniAuth::Builder do
  unless Rails.env.test?
    provider :entra_id,
      ENV.fetch("ENTRA_CLIENT_ID", "dummy"),
      ENV.fetch("ENTRA_CLIENT_SECRET", "dummy"),
      tenant_id: ENV.fetch("ENTRA_TENANT_ID", "dummy")

    provider :google_oauth2,
      ENV.fetch("GOOGLE_CLIENT_ID", "dummy"),
      ENV.fetch("GOOGLE_CLIENT_SECRET", "dummy"),
      scope: "email,profile"
  end
end

OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.silence_get_warning = true
