class Price
  attr_accessor :cents

  def initialize(cents)
    # todo cents should be positive 
    # cents should be more than zero
    @cents = cents
  end

  # no cents value
  def human_value
    @cents.to_f / 100
  end

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
