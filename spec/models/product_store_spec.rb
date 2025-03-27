# frozen_string_literal: true

require 'spec_helper'

describe ProductStore do
  let(:store) { ProductStore.new }

  describe '#create' do
    it 'agrega productos después de 5 segundos' do
      Timecop.freeze do
        store.create(name: 'Test', description: 'Test description', price: 10, stock: 1)
        sleep 5.1 # Esperar a que termine el thread
        expect(store.all_products.map(&:name)).to include('Test')
      end
    end

    it 'genera un id único para cada producto' do
      store.create(name: 'Prod1', description: 'Description 1', price: 10, stock: 1)
      store.create(name: 'Prod2', description: 'Description 2', price: 20, stock: 2)
      sleep 5.1
      expect(store.all_products.size).to eq(2)
      expect(store.all_products.map(&:id).uniq.size).to eq(2)
    end
  end

  describe '#all_products' do
    it 'retorna copia segura de los productos' do
      store.create(name: 'Test', description: 'Test description', price: 10, stock: 1)
      sleep 5.1
      products = store.all_products
      expect { products << Product.new(name: 'Evil', description: 'Esta es una descripción maliciosa muy larga', price: 1, stock: 1) }.not_to(
        change { store.all_products.size }
      )
    end
  end
end
