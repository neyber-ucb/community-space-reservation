module JsonWebToken
  extend ActiveSupport::Concern

  def encode_token(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, ENV['JWT_SECRET'] || 'default_secret_key', 'HS256')
  end

  def decode_token(token)
    begin
      JWT.decode(token, ENV['JWT_SECRET'] || 'default_secret_key', true, { algorithm: 'HS256' })
    rescue JWT::DecodeError
      nil
    end
  end
end
