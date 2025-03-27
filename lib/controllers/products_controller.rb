# frozen_string_literal: true

require_relative '../models/product_store'

class ProductsController
  def initialize(request, response)
    @request = request
    @response = response
  end

  def create
    return unless @request.post?

    body = JSON.parse(@request.body.read)
    product_id = ProductStore.instance.create(
      name: body['name'],
      description: body['description'],
      price: body['price'],
      stock: body['stock']
    )
    @response.status = 202
    @response.write({ product_id:, status: 'processing' }.to_json)
  rescue ArgumentError => e
    @response.status = 400
    @response.write({ error: e.message }.to_json)
  end

  def list
    return unless @request.get?

    products = ProductStore.instance.all_products
    @response.write(products.to_json)
  end

  def show(id)
    product = ProductStore.instance.find(id)

    if product
      @response.write(product.to_json)
    else
      @response.status = 404
      @response.write({ error: 'Producto no encontrado' }.to_json)
    end
  end
end
