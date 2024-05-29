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

  # remove one product stock
  # to do raise error if amount < 0
  def remove_items!(key, amount = 1)
    item = @items[:key]
    return if item_missing?
      
    item[:stock] -= amount
  end

  # to do raise error if amount > 0

  # add coins to stock
  def add_items!(key, amount = 1)
    item = @items[:key]
    return if item_missing?
      
    item[:stock] += amount
  end

  def item_missing?(item)
    item.nil? || item[:stock] <= 0
  end
end

