require 'securerandom'

# frozen_string_literal: true

class Product
  attr_reader :id, :name, :description, :price, :stock

  def self.validate_params(name:, description:, price:, stock:)
    raise ArgumentError, 'El nombre no puede estar vacío' if name.nil? || name.strip.empty?
    raise ArgumentError, 'El nombre debe tener entre 3 y 100 caracteres' if name.length < 3 || name.length > 100
    raise ArgumentError, 'La descripción no puede estar vacía' if description.nil? || description.strip.empty?
    raise ArgumentError, 'La descripción debe tener entre 10 y 500 caracteres' if description.length < 10 || description.length > 500
    raise ArgumentError, 'El precio debe ser un número positivo' unless price.is_a?(Numeric) && price.positive?
    raise ArgumentError, 'El stock debe ser un número entero no negativo' unless stock.is_a?(Integer) && stock >= 0
  end

  def initialize(name:, description:, price:, stock:)
    @id = SecureRandom.uuid
    @name = name
    @description = description
    @price = price
    @stock = stock
    validate!
  end

  def to_json(*_args)
    {
      id:,
      name:,
      description:,
      price:,
      stock:
    }.to_json
  end

  private

  def validate!
    self.class.validate_params(
      name: @name,
      description: @description,
      price: @price,
      stock: @stock
    )
  end
end
