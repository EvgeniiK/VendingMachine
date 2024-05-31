# frozen_string_literal: true

class Price
  attr_accessor :units, :denominations, :coins_stock

  CENTS_IN_CURRENCY = 100

  def initialize(units, coins_stock = nil)
    @units = units.abs
    @coins_stock = coins_stock&.items_in_stock
    @denominations = (@coins_stock&.keys || VendingMachine::COIN_TYPES).sort_by(&:-@)
  end

  def to_cents
    (@units * CENTS_IN_CURRENCY).to_i
  end

  def to_coins
    best_coins_combinations&.sample
  end

  def best_coins_combinations
    lowest_value = nil
    indexes = []

    all_coins_combinations.each_with_index do |combo, i|
      next unless combo[0].nil?

      coins_sum = combo.sum { |_denomination, coins_amount| coins_amount }
      if lowest_value.nil? || lowest_value > coins_sum
        indexes = [i]
        lowest_value = coins_sum
      elsif lowest_value == coins_sum
        indexes << i
      end
    end

    indexes.empty? ? nil : all_coins_combinations.values_at(*indexes)
  end

  # ex.  => [{5=>2, 2=>1}, {3=>4}, {2=>6}, {0.5=>24}, {0.25=>48}]
  def all_coins_combinations
    return @all_coins_combinations if defined?(@all_coins_combinations)

    @all_coins_combinations = denominations.each_with_index.map do |denomination, i|
      next if denomination > units

      coins_and_remains(units, denomination, i)
    end.compact
  end

  def remain_coins_calculation(amount:, start_index: 0)
    result = {}

    denominations[start_index..denominations.size].each_with_index do |denomination, i|
      next if denomination > amount
      # not enough coins found
      return { 0 => 0 } if (i - 1) < 0

      coins = coins_and_remains(amount, denomination, i - 1)
      result.merge!(coins)
      return result
    end
    # if not possible to find
    { 0 => 0 }
  end

  def coins_and_remains(amount, denomination, i)
    remains = count_remains(amount, denomination)
    result = { denomination => (amount / denomination).to_i }
    if remains != 0
      result.merge!(remain_coins_calculation(amount: remains, start_index: i))
    end

    result
  end

  def count_remains(amount, denomination)
    return amount % denomination if coins_stock.nil?

    avaliable_coins_amount = (amount / denomination).to_i
    if avaliable_coins_amount > coins_stock[denomination][:stock]
      avaliable_coins_amount = coins_stock[denomination][:stock]
    end
    amount - denomination * avaliable_coins_amount
  end
end
