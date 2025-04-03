# frozen_string_literal: true

require 'spec_helper'

describe Router do
  include Rack::Test::Methods

  let(:router) { Router.new }
  let(:request) { instance_double('Rack::Request') }
  let(:response) { instance_double('Rack::Response', :[] => nil, :[]= => nil, :write => nil, :status= => nil) }

  before do
    stub_env('TOKEN_SECRET', 'custom_secret')
  end

  describe '#route' do
    it 'enruta correctamente las solicitudes a sus controladores' do
      allow(request).to receive(:path).and_return('/auth')
      allow(request).to receive(:request_method).and_return('POST')

      expect_any_instance_of(AuthController).to receive(:authenticate)
      router.route(request, response)

      allow(request).to receive(:path).and_return('/products')
      allow(request).to receive(:request_method).and_return('GET')

      expect_any_instance_of(ProductsController).to receive(:list)
      router.route(request, response)

      allow(request).to receive(:path).and_return('/products')
      allow(request).to receive(:request_method).and_return('POST')

      expect_any_instance_of(ProductsController).to receive(:create)
      router.route(request, response)

      allow(request).to receive(:path).and_return('/products/123')
      allow(request).to receive(:request_method).and_return('GET')

      expect_any_instance_of(ProductsController).to receive(:show).with('123')
      router.route(request, response)

      allow(request).to receive(:path).and_return('/openapi.yaml')
      allow(request).to receive(:request_method).and_return('GET')

      expect_any_instance_of(StaticController).to receive(:serve_file).with('openapi.yaml', 'text/yaml', 'no-cache, no-store, must-revalidate')
      router.route(request, response)
    end

    it 'retorna 404 para rutas no encontradas' do
      allow(request).to receive(:path).and_return('/ruta-que-no-existe')
      allow(request).to receive(:request_method).and_return('GET')

      expect(response).to receive(:status=).with(404)
      expect(response).to receive(:write).with({ error: 'Ruta no encontrada' }.to_json)

      router.route(request, response)
    end
  end
end
