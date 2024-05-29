class Coin
  CENTS_IN_CURRENCY = 100

  def initialize(denomination)
    @denomination = denomination
    @cents = (denomination * CENTS_IN_CURRENCY).to_i
  end
end
