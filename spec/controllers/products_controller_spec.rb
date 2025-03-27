# frozen_string_literal: true

require 'spec_helper'

describe ProductsController do
  include Rack::Test::Methods

  def app
    @app ||= Rack::Builder.new do
      use Rack::Deflater
      use AuthMiddleware, ['/products']
      run App.new
    end
  end

  let(:token) { JWT.encode({ user: 'admin' }, Config.token_secret, 'HS256') }
  let(:valid_product) do
    {
      name: 'Producto de prueba',
      description: 'Este es un producto de prueba con una descripción válida',
      price: 99.99,
      stock: 10
    }
  end

  before do
    stub_env('TOKEN_SECRET', 'custom_secret')
  end

  describe '#create' do
    it 'acepta creación asíncrona con datos válidos' do
      post '/products', valid_product.to_json,
           'HTTP_AUTHORIZATION' => "Bearer #{token}"
      expect(last_response.status).to eq(202)
      expect(last_response.json).to include('product_id')
    end

    it 'rechaza sin autenticación' do
      post '/products', valid_product.to_json
      expect(last_response.status).to eq(401)
    end

    context 'validaciones' do
      it 'rechaza nombre vacío' do
        product = valid_product.merge(name: '')
        post '/products', product.to_json,
             'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(400)
        expect(last_response.json['error']).to include('El nombre no puede estar vacío')
      end

      it 'rechaza nombre muy corto' do
        product = valid_product.merge(name: 'ab')
        post '/products', product.to_json,
             'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(400)
        expect(last_response.json['error']).to include('El nombre debe tener entre 3 y 100 caracteres')
      end

      it 'rechaza descripción vacía' do
        product = valid_product.merge(description: '')
        post '/products', product.to_json,
             'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(400)
        expect(last_response.json['error']).to include('La descripción no puede estar vacía')
      end

      it 'rechaza descripción muy corta' do
        product = valid_product.merge(description: 'corta')
        post '/products', product.to_json,
             'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(400)
        expect(last_response.json['error']).to include('La descripción debe tener entre 10 y 500 caracteres')
      end

      it 'rechaza precio negativo' do
        product = valid_product.merge(price: -10)
        post '/products', product.to_json,
             'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(400)
        expect(last_response.json['error']).to include('El precio debe ser un número positivo')
      end

      it 'rechaza stock negativo' do
        product = valid_product.merge(stock: -5)
        post '/products', product.to_json,
             'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.status).to eq(400)
        expect(last_response.json['error']).to include('El stock debe ser un número entero no negativo')
      end
    end
  end

  describe '#list' do
    context 'cuando se solicita compresión gzip' do
      it 'devuelve una respuesta comprimida' do
        get '/products', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}", 'HTTP_ACCEPT_ENCODING' => 'gzip'
        expect(last_response.headers['content-encoding']).to eq('gzip')
        decompressed = Zlib::GzipReader.new(StringIO.new(last_response.body)).read
        expect { JSON.parse(decompressed) }.not_to raise_error
      end
    end

    context 'cuando no se solicita compresión' do
      it 'devuelve una respuesta sin comprimir' do
        get '/products', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"
        expect(last_response.headers['content-encoding']).to be_nil
        expect { JSON.parse(last_response.body) }.not_to raise_error
      end
    end
  end

  describe '#show' do
    let(:product_id) { nil }

    before do
      # Crear un producto para probar
      post '/products', valid_product.to_json, 'HTTP_AUTHORIZATION' => "Bearer #{token}"
      @product_id = last_response.json['product_id']
      sleep 5.1 # Esperar a que el producto esté disponible
    end

    it 'retorna los detalles de un producto existente' do
      get "/products/#{@product_id}", {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"
      expect(last_response.status).to eq(200)
      expect(last_response.json).to include('id', 'name', 'description', 'price', 'stock')
      expect(last_response.json['name']).to eq('Producto de prueba')
    end

    it 'retorna 404 para un producto que no existe' do
      get '/products/nonexistent-id', {}, 'HTTP_AUTHORIZATION' => "Bearer #{token}"
      expect(last_response.status).to eq(404)
      expect(last_response.json).to include('error')
    end

    it 'requiere autenticación' do
      get "/products/#{@product_id}"
      expect(last_response.status).to eq(401)
    end
  end
end
