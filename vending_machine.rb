require_relative 'stock'
require_relative 'product'
require_relative 'coin'
require_relative 'price'
require_relative 'vm_interface'

class VendingMachine
	STEPS = %i[select_product coins_input result]
	DEFAULT_STOCK_AMOUNT = 10
  COIN_TYPES = [0.25, 0.5, 1, 3, 5]
	INITIAL_PRODUCTS_VALUE = {candy: {stock: 10, price_cents: 250},
													  chocolate: {stock: 1, price_cents: 125}, 
														nuts: {stock: 2, price_cents: 110},
														cola: {stock:5, price_cents: 1200}
													}
													

	def self.interact
		vm = VendingMachine.new
		vm_interface = VmInterface.new(vm)

		product = nil


		puts '~~~~~~~~~~~~~~~~~~~~~~~~~~'

		ARGF.each_line do |line|

			case STEPS[vm.step]
			when :select_product
				
				vm_interface.avaliable_products

				input_value = vm.read_input(line)
				next unless input_value


				product = vm.select_product(input_value)
				vm_interface.type_a_number
				product ? vm.next_step! : vm_interface.select_again
			when :coins_input
				vm_interface.selected_product(product)
				vm_interface.amount_inserted(vm.amount_inserted)

				vm_interface.avaliable_coins(COIN_TYPES)
				vm_interface.type_a_number

				input_value = vm.read_input(line)
				next unless input_value

				vm_interface.amount_inserted(vm.amount_inserted)

				vm.add_coin(input_value)
				vm.next_step! if product.price.human_value <= vm.amount_inserted
			when :result
				vm.add_coins_to_stock
				change = vm.give_change

				# todo think how to make it better
				if change.nil?
					vm_interface.unavaliable_change
					return vm.abort_operation!
				end
				vm.remove_product_stock(product)
				vm_interface.give_change(change)
				vm_interface.give_product(product)

				vm.next_step 
			else
				p STEPS[vm.step]
				# abort operation
			end
				
		end

		puts '~~~~~~~~~~~~~~~~~~~~~~~~~~'
	end
	
  attr_accessor :product_stock, :coins_stock, :step, :coins_inserted
	
  def initialize
		@product_stock = Stock.new(initial_product_stock)
		@coins_stock = Stock.new(initial_coin_stock)
		@step = 0
		@coins_inserted = {}

# todo if price 1200 but there is no 200 left - it is 4 coins 5, 5, 1, 1 
# but better to give 3, 3, 3
		p Price.new(1200).to_coins(denominations: COIN_TYPES)
  end

	# todo add abort command here
	def read_input(line)

		# todo empty line is '/n' 

		line.to_i
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

	# result: {type: {item: coin, stock: stock_size}}
	def initial_coin_stock
		COIN_TYPES.inject({}) { |hash, type| hash.merge(type => { item: Coin.new(type), stock: DEFAULT_STOCK_AMOUNT } ) }
	end

	def add_coins_to_stock
# todo
	end

	def give_change
# todo

	end

	def abort_operation!
# todo
	end

	def remove_product_stock(product)
		product_stock.remove_items(product.button_number)
	end

	# result: {type: {item: product, stock: stock_size}}
	def initial_product_stock
		result = {}
		INITIAL_PRODUCTS_VALUE.each_with_index do |(name, meta), i| 
			price = Price.new(meta[:price_cents])
			product = Product.new(name: :cola, button_number: i, price: price)
			result[i] = { item: product, stock: DEFAULT_STOCK_AMOUNT }
		end

		result
	end
end

VendingMachine.interact
