# frozen_string_literal: true

class Config
  def self.token_secret
    ENV.fetch('TOKEN_SECRET',nil)
  end
end
