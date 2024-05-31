# frozen_string_literal: true

require_relative '../vending_machine'

describe Price do
  let(:units) { 12 }
  let(:coin_types) { [0.25, 0.5, 1, 2, 3, 5] }
  let(:deault_stock_amount) { 1 }

  before do
    stub_const 'VendingMachine::COIN_TYPES', coin_types
    stub_const 'VendingMachine::DEFAULT_STOCK_AMOUNT', deault_stock_amount
  end

  describe '.to_coins' do
    subject { described_class.new(units).to_coins }

    context 'without stock' do
      it 'returns coins combination' do
        expect(subject).to eq(5 => 2, 2 => 1)
      end

      context 'when multiple options' do
        let(:coin_types) { [0.25, 3, 5] }

        it 'returns best coins combination' do
          expect(subject).to eq(3 => 4)
        end
      end

      context 'when no coins possible' do
        let(:units) { 0.1 }

        it 'returns nothing' do
          expect(subject).to be_nil
        end
      end
    end

    context 'with stock' do
      subject { described_class.new(units, stock).to_coins }

      let(:coins_amount) { { 0.25 => { stock: 10 }, 3 => { stock: 5 }, 2 => { stock: 5 }, 5 => { stock: 5 } } }
      let(:stock) { Stock.new(coins_amount) }

      it 'returns best coins combination' do
        expect(subject).to eq(5 => 2, 2 => 1)
      end

      context 'when missing coins for best combination' do
        let(:coins_amount) { { 0.25 => { stock: 10 }, 3 => { stock: 5 }, 5 => { stock: 5 } } }

        it 'returns other best combination' do
          expect(subject).to eq(3 => 4)
        end
      end

      context 'when just enough coins' do
        let(:coin_types) { [0.5, 1.5, 2, 3, 5] }
        let(:coins_amount) { coin_types.inject({}) { |h, key| h.merge(key => { stock: 1 }) } }

        it 'returns all' do
          expect(subject.keys).to eq(coin_types.reverse)
        end
      end

      context 'when not enough coins' do
        let(:coin_types) { [0.5, 1, 2, 3, 5] }
        let(:coins_amount) { coin_types.inject({}) { |h, key| h.merge(key => { stock: 1 }) } }

        it 'returns nothing' do
          expect(subject).to be_nil
        end
      end

      context 'when price change is impossible' do
        let(:units) { 12.1 }

        it 'returns nothing' do
          expect(subject).to be_nil
        end
      end
    end
  end
end
