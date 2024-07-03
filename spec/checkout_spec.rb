# frozen_string_literal: true

require_relative '../checkout'

# rubocop:disable Metrics/BlockLength
describe Checkout do
  describe '.new' do
    subject { described_class.new(args) }

    context 'whith the argument' do
      context 'when the argument is empty' do
        let(:args) { [] }

        it 'raises an error' do
          expect { subject }.to raise_error ArgumentError
        end
      end

      context 'when the argument is present' do
        context 'when the argument items are incorrect' do
          context 'when the item is a string' do
            let(:args) { [''] }

            it 'raises an error' do
              expect { subject }.to raise_error ArgumentError
            end
          end

          context 'when the item is a invalid hash' do
            let(:args) { [{ invalid: 'invalid' }] }

            it 'raises an error' do
              expect { subject }.to raise_error ArgumentError, /params are required/
            end
          end
        end

        context 'when the argument items are correct' do
          let(:args) { [{ min_quantity: 1, discount: 50, codes: ['GR1'] }] }

          it 'not raises an arror' do
            expect { subject }.not_to raise_error
          end

          it 'creates a pricting_rules Struct' do
            expect(subject.pricing_rules.first.is_a?(Struct)).to be true
          end

          it 'assights the correct attributes to the pricing_rules' do
            expect(subject.pricing_rules.first).to have_attributes(
              min_quantity: 1, discount: 50, codes: ['GR1']
            )
          end
        end
      end
    end

    context 'without arguments' do
      let(:args) { nil }

      it 'raises an error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#scan' do
    subject { co.scan(item) }

    let(:co) { Checkout.new(pricing_rules) }
    let(:pricing_rules) { [{ min_quantity: 1, discount: 50, codes: ['GR1'] }] }

    context 'when the item is empty' do
      let(:item) { '' }

      it 'returns the error message' do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context 'when the item is out of scope' do
      let(:item) { 'GX' }

      it 'returns the error message' do
        expect(subject).to eq 'Product with the code GX is out of stock'
      end
    end

    context 'when the item exists' do
      let(:item) { 'GR1' }

      it 'returns one' do
        expect(subject).to eq 1
      end

      it 'changes product quantity from 0 to 1' do
        subject
        expect(co.send(:products).find { |p| p.code == 'GR1' }.quantity).to eq 1
      end
    end
  end

  describe '#total' do
    subject { co.total }

    let(:pricing_rules) do
      [
        {
          min_quantity: 1,
          discount: 50,
          codes: ['GR1']
        },
        {
          min_quantity: 3,
          discount: 10,
          codes: ['SR1']
        },
        {
          min_quantity: 3,
          discount: 33.33,
          codes: ['CF1']
        }
      ]
    end

    let(:co) { Checkout.new(pricing_rules) }

    context 'when basket GR1,SR1,GR1,GR1,CF1' do
      before { %w[GR1 SR1 GR1 GR1 CF1].each { |item| co.scan(item) } }

      it 'returns the correct value' do
        expect(subject).to eq '£22.45'
      end
    end

    context 'when basket GR1 GR1' do
      before { %w[GR1 GR1].each { |item| co.scan(item) } }

      it 'returns the correct value' do
        expect(subject).to eq '£3.11'
      end
    end

    context 'when basket SR1,SR1,GR1,SR1' do
      before { %w[SR1 SR1 GR1 SR1].each { |item| co.scan(item) } }

      it 'returns the correct value' do
        expect(subject).to eq '£16.61'
      end
    end

    context 'when basket GR1,CF1,SR1,CF1,CF1' do
      before { %w[GR1 CF1 SR1 CF1 CF1].each { |item| co.scan(item) } }

      it 'returns the correct value' do
        expect(subject).to eq '£30.57'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
