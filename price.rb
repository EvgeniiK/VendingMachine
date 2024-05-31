class Price
  attr_accessor :cents, :denominations, :coins_stock

  def initialize(cents, coins_stock = nil)
    # todo cents should be positive 
    # cents should be more than zero
    @cents = cents
    @coins_stock = coins_stock
    @denominations = (coins_stock&.keys || VendingMachine::COIN_TYPES).sort_by { |e| -e }
  end

  # no cents value
  def human_value
    @cents.to_f / 100
  end

  def to_coins_with_stocks(coins_stock)


    # tree = {}
    # [1200].each_with_index do |d, i|
    #   tree[d] = all_options_for(d)
    # end
    # tree
  end

  # todo can be several
  def best_coins_combination
    combos = all_coins_combinations

    lowest_value = nil
    index = 0
    all_coins_combinations.each_with_index do |combo, i|
      combo_sum = combo.sum { |_k, v| v }
      if lowest_value.nil? || lowest_value > combo_sum
        index = i 
        lowest_value = combo_sum
      end
    end

    combos[index]
  end

  def all_coins_combinations(amount: cents, start_index: 0)
    return if amount.to_i == 0

    (start_index..denominations.size - 1).map do |i|
      denomination = denominations[i]

      next if amount < denomination

      remains = count_remains(amount, denomination)
      result = [{ denomination => (amount / denomination).to_i }]
      # todo it is only for recuring :\ because of start_index presence
      return result if start_index != 0 && remains == 0
      # todo calulate all possible options if remains like: 12 => 5,5,2; 12=>3,3,3,3; 12=>3,3,5,1
      # todo think if it is nescesarry? 
      # maybe I need to create a hash like best for 5 => 2,2,1
      result += (all_coins_combinations(amount: remains, start_index: i + 1)) if remains != 0
      result
    end.compact
  end

  def a(amount: cents)
    denominations.each_with_index.map do |denomination, i|
      result, remains = result_and_remains(amount, denomination, i)
      result
    end
  end

  def b(amount:, start_index: 0)
    res = {}
    (start_index..denominations.size - 1).each do |i|
      denomination = denominations[i]
      next if denomination > amount
      result, remains = result_and_remains(amount, denomination, i)
      res.merge!(result)
      return res if remains == 0
    end
    {nil: nil}
  end

  def result_and_remains(amount, denomination, i)
    remains = count_remains(amount, denomination)
    result = { denomination => (amount / denomination).to_i }
    result.merge!(b(amount: remains, start_index: i + 1)) if remains != 0
    [result, remains]
  end

  def count_remains(amount, denomination)
    return amount % denomination if coins_stock.nil?

    needed_coins_amount = amount / denomination
    # just another option
    # needed_coins_amount = coins_stock[denomination][:stock] if needed_coins_amount > coins_stock[denomination][:stock]
    avaliable_coins_amount = coins_size > coins_stock[denomination][:stock] ? coins_stock[denomination][:stock] : needed_coins_amount
    amount - denomination * avaliable_coins_amount
  end

# todo if price 1200 but there is no 200 left - it is 4 coins 5, 5, 1, 1 
# but better to give 3, 3, 3
		# p Price.new(1200).to_coins(denominations: COIN_TYPES)
  def to_coins(denominations: VendingMachine::COIN_TYPES)
    # todo replace with the coin object
    denominations = denominations.sort_by { |e| -e }
    denominations = denominations.map { |e| e*100 }


    total_leftover = cents
    denominations.inject({}) do |hash, denomination|
      # return if total_leftover == 0

      coins_leftover = total_leftover % denomination

      coins_amount = (total_leftover - coins_leftover) / denomination
      total_leftover = coins_leftover
      # todo check it
      return hash.merge({ denomination => coins_amount }) if total_leftover == 0
      
      hash.merge({ denomination => coins_amount })

    end
  end

  # Todo ?? or move to coins??
  def to_coins_with_stocks(coins_stock)
    denominations = coins_stock.keys


  end
end
