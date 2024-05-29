class VmInterface
  def initialize(vending_machine)
    @vending_machine = vending_machine
  end

  def avaliable_products
    # write a notice if nothing left
    @vending_machine.product_stock.items_in_stock.each do |(button_number, stock_info)|
      product = stock_info[:item]
      p "#{button_number}: #{product.name}, price: #{product.price.human_value}"
    end
  end

  def selected_product(product)
    p "Selected product: #{product.name}, price: #{product.price.human_value}"
  end

  def select_again
    p 'Please select again'
  end

  def amount_inserted(amount_inserted)
    p "Inserted amount: #{amount_inserted}"
  end

  def type_a_number
    p 'Please select a number'
  end

  def avaliable_coins(coin_types)
    p coin_types.each_with_index.map { |type, i | "#{i}: (#{type})"}.join(';  ')
  end

  def unavaliable_change
    'Abort operation. Not enough coins for change'
  end

  def give_change(coins)
    # todo
    'your chaange'
  end

  def give_product(product)
    # todo
    'your product'
  end

end
