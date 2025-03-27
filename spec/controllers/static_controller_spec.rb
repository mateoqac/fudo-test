# frozen_string_literal: true

require 'spec_helper'

describe StaticController do
  include Rack::Test::Methods

  def app
    # Los archivos estáticos no requieren autenticación
    @app ||= Rack::Builder.new do
      use Rack::Deflater
      run App.new
    end
  end

  describe '#serve_file' do
    it 'sirve openapi.yaml sin caché' do
      get '/openapi.yaml'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['cache-control']).to eq('no-cache, no-store, must-revalidate')
      expect(last_response.body).to include('openapi:')
      expect(last_response.body).to include('Product API')
    end

    it 'sirve AUTHORS con caché de 24h' do
      get '/AUTHORS'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['cache-control']).to eq('public, max-age=86400')
      expect(last_response.body).to include('Mateo Avantaggiato')
    end

    it 'retorna 404 para un archivo que no existe' do
      get '/nonexistent-file.txt'
      expect(last_response.status).to eq(404)
    end
  end
end
