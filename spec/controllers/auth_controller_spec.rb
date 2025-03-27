# frozen_string_literal: true

require 'spec_helper'

describe AuthController do
  include Rack::Test::Methods

  def app
    # No utilizamos AuthMiddleware para la ruta /auth porque
    # es precisamente el endpoint para obtener el token de autenticación
    @app ||= Rack::Builder.new do
      use Rack::Deflater
      run App.new
    end
  end

  before do
    stub_env('TOKEN_SECRET', 'custom_secret')
  end

  describe '#authenticate' do
    it 'retorna token con credenciales válidas' do
      post '/auth', { user: 'admin', password: 'secret' }.to_json
      expect(last_response.status).to eq(200)
      expect(last_response.json).to include('token')
    end

    it 'rechaza credenciales inválidas' do
      post '/auth', { user: 'wrong', password: 'bad' }.to_json
      expect(last_response.status).to eq(401)
    end
  end
end
