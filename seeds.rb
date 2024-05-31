# frozen_string_literal: true

class Seeds
  # result: {type: {item: coin, stock: stock_size}}
  def self.initial_coin_stock
    VendingMachine::COIN_TYPES.inject({}) { |hash, type| hash.merge(type => { stock: VendingMachine::DEFAULT_STOCK_AMOUNT }) }
  end

  # result: {type: {item: product, stock: stock_size}}
  def self.initial_product_stock
    result = {}
    VendingMachine::INITIAL_PRODUCTS_VALUE.each_with_index do |(name, meta), i|
      price = Price.new(meta[:unit_cost])
      product = Product.new(name: name, button_number: i, price: price)
      result[i] = { item: product, stock: VendingMachine::DEFAULT_STOCK_AMOUNT }
    end

    result
  end
end
