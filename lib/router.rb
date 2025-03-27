# frozen_string_literal: true

require_relative 'controllers/auth_controller'
require_relative 'controllers/products_controller'
require_relative 'controllers/static_controller'

class Router
  ROUTES = [
    {
      path: '/auth',
      method: 'POST',
      controller: AuthController,
      action: :authenticate
    },
    {
      path: '/products',
      method: 'POST',
      controller: ProductsController,
      action: :create
    },
    {
      path: '/products',
      method: 'GET',
      controller: ProductsController,
      action: :list
    },
    {
      path: %r{^/products/([^/]+)$},
      method: 'GET',
      controller: ProductsController,
      action: :show
    },
    # Static files
    {
      path: '/openapi.yaml',
      method: 'GET',
      controller: StaticController,
      action: :serve_file,
      args: ['openapi.yaml', 'text/yaml', 'no-cache, no-store, must-revalidate']
    },
    {
      path: '/AUTHORS',
      method: 'GET',
      controller: StaticController,
      action: :serve_file,
      args: ['AUTHORS', 'text/plain', 'public, max-age=86400']
    }
  ].freeze

  def self.routes
    ROUTES
  end

  def route(request, response)
    path = request.path
    method = request.request_method

    route = self.class.routes.find do |r|
      path_match = case r[:path]
                   when String
                     path == r[:path]
                   when Regexp
                     path =~ r[:path]
                   end
      path_match && (r[:method].nil? || r[:method] == method)
    end

    if route
      captures = []
      if route[:path].is_a?(Regexp) && (match = path.match(route[:path]))
        captures = match.captures
      end

      controller = route[:controller].new(request, response)

      if route[:args] && !route[:args].empty?
        controller.send(route[:action], *route[:args])
      else
        controller.send(route[:action], *captures)
      end
    else
      response.status = 404
      response.write({ error: 'Ruta no encontrada' }.to_json)
    end
  end
end
