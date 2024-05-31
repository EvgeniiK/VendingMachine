class Messaging
  def select_product_step(products)
    avaliable_products(products)
    type_a_number
  end

  def coins_input_step(product, amount_inserted)
    selected_product(product)
    amount_inserted(amount_inserted)
    avaliable_coins(VendingMachine::COIN_TYPES)
    type_a_number
  end

  def avaliable_products(products)
    return p 'No products left' if products.empty?
    
    products.each do |(button_number, stock_info)|
      product = stock_info[:item]
      p "#{button_number}: #{product.name}, price: #{product.price.units}"
    end
  end

  def selected_product(product)
    p "Selected product: #{product.name}, price: #{product.price.units}"
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
    p 'Abort operation. Not enough coins for change'
  end

  def give_change(change)
    if change.empty?
      p 'No change needed'
    else
      p "Your change: #{change.to_a.map { |ch| ch.join('*') }.join('; ')}"      
    end
  end

  def give_product(product)
    p "Here is your product: #{product.name}"
  end

  def your_input(number)
    p number ? "You pressed: #{number}" : "Wrong input"
  end

  def something_wrong
    'Something went wrong'
  end
end
