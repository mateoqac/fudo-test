# frozen_string_literal: true

class StaticController
  def initialize(request, response)
    @request = request
    @response = response
  end

  def serve_file(filename = nil, content_type = nil, cache_control = nil)
    # Si no se proporcionan argumentos, intentar obtenerlos de la ruta
    route = Router.routes.find { |r| r[:path] == @request.path && r[:controller] == self.class }

    filename ||= route&.dig(:args, 0)
    content_type ||= route&.dig(:args, 1)
    cache_control ||= route&.dig(:args, 2)

    return unless filename && content_type && cache_control

    file_path = File.join(File.dirname(__FILE__), '..', '..', 'public', filename)
    if File.exist?(file_path)
      @response['Content-Type'] = content_type
      @response['Cache-Control'] = cache_control
      @response.write(File.read(file_path))
    else
      @response.status = 404
      @response.write({ error: 'No encontrado' }.to_json)
    end
  end
end
