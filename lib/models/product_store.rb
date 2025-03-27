# frozen_string_literal: true

require 'securerandom'

class ProductStore
  attr_accessor :products

  def self.instance
    @instance ||= new
  end

  def initialize
    @products = {}
    @mutex = Mutex.new
  end

  def create(name:, description:, price:, stock:)
    Product.validate_params(name:, description:, price:, stock:)

    product_id = SecureRandom.uuid
    Thread.new do
      sleep 5 # Simular procesamiento asíncrono
      product = Product.new(name:, description:, price:, stock:)
      @mutex.synchronize do
        @products[product_id] = product
      end
    end
    product_id
  end

  def all_products
    @mutex.synchronize do
      @products.values
    end
  end

  def find(id)
    @mutex.synchronize do
      @products[id]
    end
  end
end
