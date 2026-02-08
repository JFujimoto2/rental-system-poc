Rails.application.config.middleware.use OmniAuth::Builder do
  unless Rails.env.test?
    if ENV["ENTRA_CLIENT_ID"].present?
      provider :entra_id,
        ENV["ENTRA_CLIENT_ID"],
        ENV["ENTRA_CLIENT_SECRET"],
        tenant_id: ENV["ENTRA_TENANT_ID"]
    end

    if ENV["GOOGLE_CLIENT_ID"].present?
      provider :google_oauth2,
        ENV["GOOGLE_CLIENT_ID"],
        ENV["GOOGLE_CLIENT_SECRET"],
        scope: "email,profile"
    end
  end
end

OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.silence_get_warning = true
