class Product
  attr_reader :name, :button_number, :price

  def initialize(name: , button_number: , price: )
    @button_number = button_number
    @name = name
    @price = price
  end
end