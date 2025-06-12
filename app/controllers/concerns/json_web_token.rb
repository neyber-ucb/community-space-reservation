module JsonWebToken
  extend ActiveSupport::Concern
  
  def encode_token(payload, exp = 24.hours.from_now)
    # Add expiration to payload
    payload_copy = payload.dup
    payload_copy[:exp] = exp.to_i
    
    begin
      JWT.encode(payload_copy, secret_key, 'HS256')
    rescue JWT::EncodeError => e
      Rails.logger.error("Error encoding token: #{e.message}")
      nil
    end
  end
  
  def decode_token(token)
    begin
      JWT.decode(token, secret_key, true, { algorithm: 'HS256' })
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
      Rails.logger.error("Error decoding token: #{e.message}")
      nil
    end
  end
  
  private
  
  def secret_key
    ENV['JWT_SECRET'] || 'default_secret_key'
  end
end
