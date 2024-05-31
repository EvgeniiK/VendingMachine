# frozen_string_literal: true

require_relative 'stock'
require_relative 'product'
require_relative 'price'
require_relative 'messaging'
require_relative 'seeds'

class VendingMachine
  STEPS = %i[select_product coins_input give_product].freeze
  DEFAULT_STOCK_AMOUNT = 1
  MAX_INPUT_VALUE_SIZE = 2
  COIN_TYPES = [0.25, 0.5, 1, 2, 3, 5].freeze
  INITIAL_PRODUCTS_VALUE = { candy: { stock: 10, unit_cost: 2.5 },
                             chocolate: { stock: 1, unit_cost: 1.25 },
                             nuts: { stock: 2, unit_cost: 1.1 },
                             cola: { stock: 5, unit_cost: 12 } }.freeze

  def self.interact(vending_machine: nil)
    vm = vending_machine || VendingMachine.new

    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~'
    case STEPS[vm.step]
    when :select_product
      vm.select_product_step
    when :coins_input
      vm.coins_input_step
    when :give_product
      vm.give_product_step
    else
      vm.reset_state
      vm.messaging.something_wrong
     end
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~'

    VendingMachine.interact(vending_machine: vm)
  end

  attr_accessor :product_stock, :coins_stock, :step, :coins_inserted, :selected_product, :messaging

  def initialize
    @product_stock = Stock.new(Seeds.initial_product_stock)
    @coins_stock = Stock.new(Seeds.initial_coin_stock)
    @messaging = Messaging.new
    reset_state
  end

  def process_input(line, possible_numbers)
    number = line.gsub(/[^0-9]/, '')
    return if number.empty? ||
              number.size > MAX_INPUT_VALUE_SIZE ||
              !possible_numbers.include?(number.to_i)

    number.to_i
  end

  def select_product_step
    messaging.select_product_step(product_stock.items_in_stock)

    ARGF.each_line do |line|
      input_value = process_input(line, product_stock.items_in_stock.keys)
      messaging.your_input(input_value)
      next unless input_value

      @selected_product = select_product(input_value)
      if selected_product
        next_step
        return
      end
    end
  end

  def coins_input_step
    messaging.coins_input_step(selected_product, amount_inserted)

    ARGF.each_line do |line|
      input_value = process_input(line, (0...COIN_TYPES.size).to_a)
      messaging.your_input(input_value)
      next unless input_value

      add_coin(input_value)

      messaging.coins_input_step(selected_product, amount_inserted)

      if selected_product.price.units <= amount_inserted
        next_step
        return
      end
    end
  end

  def give_product_step
    add_inserted_coins_to_stock

    if change.nil?
      remove_inserted_coins_from_stock

      messaging.unavaliable_change
    else
      update_stocks

      messaging.give_change(change)
      messaging.give_product(selected_product)
    end

    reset_state
  end

  def select_product(button_number)
    product_stock.item(button_number)[:item]
  end

  def next_step
    return @step = 0 if @step + 1 > STEPS.size

    @step += 1
  end

  def add_coin(coin_index)
    coins_inserted[COIN_TYPES[coin_index]] ||= 0
    coins_inserted[COIN_TYPES[coin_index]] += 1
  end

  def amount_inserted
    coins_inserted.sum { |k, v| k * v }
  end

  def add_inserted_coins_to_stock
    coins_inserted.each do |denomination, coins_amount|
      coins_stock.add_items(denomination, coins_amount)
    end
  end

  def remove_inserted_coins_from_stock
    coins_inserted.each do |denomination, coins_amount|
      coins_stock.remove_items(denomination, coins_amount)
    end
  end

  def remove_change_from_stock
    change.each do |denomination, coins_amount|
      coins_stock.remove_items(denomination, coins_amount)
    end
  end

  def change
    return @change unless @change.nil?

    change_amount = amount_inserted - selected_product.price.units
    return @change = [] if change_amount == 0

    @change = Price.new(change_amount, coins_stock).to_coins
  end

  def update_stocks
    remove_product_stock
    remove_change_from_stock
  end

  def reset_state
    @select_product = nil
    @step = 0
    @coins_inserted = {}
    @change = nil
  end

  def remove_product_stock
    product_stock.remove_items(selected_product.button_number)
  end
end
