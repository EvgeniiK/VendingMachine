require_relative 'stock'
require_relative 'product'
require_relative 'coin'
require_relative 'price'
require_relative 'messaging'
require_relative 'seeds'

class VendingMachine
	STEPS = %i[select_product coins_input give_product]
	DEFAULT_STOCK_AMOUNT = 1
  COIN_TYPES = [0.25, 0.5, 1, 3, 5]
	INITIAL_PRODUCTS_VALUE = {candy: {stock: 10, price_cents: 250},
													  chocolate: {stock: 1, price_cents: 125}, 
														nuts: {stock: 2, price_cents: 110},
														cola: {stock:5, price_cents: 1200}
													}
													

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
        p vm.messaging.something_wrong
			end
		puts '~~~~~~~~~~~~~~~~~~~~~~~~~~'

    VendingMachine.interact(vending_machine: vm)
	end
	
  attr_accessor :product_stock, :coins_stock, :step, :coins_inserted, :selected_product, :messaging
	
  def initialize
		@product_stock = Stock.new(Seeds.initial_product_stock)
		@coins_stock = Stock.new(Seeds.initial_coin_stock)
    @messaging = Messaging.new
    reset_state!

# todo if price 1200 but there is no 200 left - it is 4 coins 5, 5, 1, 1 
# but better to give 3, 3, 3
		# p Price.new(1200).to_coins(denominations: COIN_TYPES)
  end

	def read_input(line, possible_numbers)
    number = line.gsub(/[^0-9]/, '')
    return if number.empty? || !possible_numbers.include?(number.to_i)

		number.to_i
	end

  def select_product_step
    messaging.select_product_step(product_stock.items_in_stock)

    ARGF.each_line do |line|
      input_value = read_input(line, product_stock.items_in_stock.keys)
      messaging.your_input(input_value)
      next unless input_value

      @selected_product = select_product(input_value)
      if selected_product
        next_step!
        return
      end
    end
  end

  def coins_input_step
    messaging.coins_input_step(selected_product, amount_inserted)

    ARGF.each_line do |line|
      input_value = read_input(line, (0...COIN_TYPES.size).to_a)
      messaging.your_input(input_value)
      next unless input_value

      add_coin(input_value)

      messaging.coins_input_step(selected_product, amount_inserted)

      if selected_product.price.human_value <= amount_inserted
        next_step! 
        return
      end
    end
  end

  def give_product_step
    # stock_with_new_coins
    
    # add_coins_to_stock
    # change = give_change

    if change.nil?
      messaging.unavaliable_change

      abort_operation!
    else
      messaging.give_change(change)
      messaging.give_product(selected_product)
  
      finish_operation! 
    end
    
    reset_state!
  end

	def select_product(button_number)
		product_stock.item(button_number)[:item]
	end

	def next_step!
		return @step = 0 if @step + 1 > STEPS.size

		@step += 1
	end

	def add_coin(coin_index)
		coins_inserted[COIN_TYPES[coin_index]] ||= 0
		coins_inserted[COIN_TYPES[coin_index]] += 1
	end

	def amount_inserted
		coins_inserted.sum { |k,v| k*v }
	end

	def add_coins_to_stock

# todo
	end

  def remove_coins_from_stock!
# todo
  end

	def change
    # todo with stocks
    Price.new(amount_inserted- selected_product.price.cents).to_coins
	end

  def finish_operation!
    remove_product_stock!
  end

	def abort_operation!
    remove_coins_from_stock!
	end
  
  def reset_state!
    @select_product = nil
    @step = 0
    @coins_inserted = {}
  end

	def remove_product_stock!
		product_stock.remove_items!(selected_product.button_number)
	end
end

VendingMachine.interact
