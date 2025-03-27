# frozen_string_literal: true

require_relative 'controllers/auth_controller'
require_relative 'controllers/products_controller'
require_relative 'controllers/static_controller'

class Router
  @@routes = []

  def self.routes
    @@routes
  end

  def initialize
    setup_routes if @@routes.empty?
  end

  def route(request, response)
    path = request.path
    method = request.request_method

    route = @@routes.find do |r|
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

  private

  def setup_routes
    # Auth routes
    @@routes << {
      path: '/auth',
      method: 'POST',
      controller: AuthController,
      action: :authenticate
    }

    # Products routes
    @@routes << {
      path: '/products',
      method: 'POST',
      controller: ProductsController,
      action: :create
    }

    @@routes << {
      path: '/products',
      method: 'GET',
      controller: ProductsController,
      action: :list
    }

    @@routes << {
      path: /^\/products\/([^\/]+)$/,
      method: 'GET',
      controller: ProductsController,
      action: :show
    }

    # Static files
    @@routes << {
      path: '/openapi.yaml',
      method: 'GET',
      controller: StaticController,
      action: :serve_file,
      args: ['openapi.yaml', 'text/yaml', 'no-cache, no-store, must-revalidate']
    }

    @@routes << {
      path: '/AUTHORS',
      method: 'GET',
      controller: StaticController,
      action: :serve_file,
      args: ['AUTHORS', 'text/plain', 'public, max-age=86400']
    }
  end
end
