class Stock
  # format: {key: {stock: stock_size}}
  def initialize(items)
    @items = items
  end

  def item(key)
    @items[key]
  end

  def items_in_stock
    @items.select { |_key, item| item[:stock] > 0 }
  end

  def remove_items!(key, amount = 1)
    item = @items[key]
    return if item_missing?(item) || not_enough_amount?(item, amount)
    
    item[:stock] -= amount
  end

  def add_items!(key, amount = 1)
    item = @items[:key]
    return if item_missing?(item)
      
    item[:stock] += amount
  end

  def item_missing?(item)
    item.nil?
  end

  def not_enough_amount?(item, amount)
    item[:stock] - amount <= 0
  end
end

