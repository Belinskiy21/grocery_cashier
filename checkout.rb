# frozen_string_literal: true

# add items to the basket and calculate total price
class Checkout
  attr_accessor :product, :pricing_rules

  PRODUCTS = [
    { code: 'GR1', name: 'Green tea', price: 3.11 },
    { code: 'SR1', name: 'Strawberries', price: 5.00 },
    { code: 'CF1', name: 'Coffee', price: 11.23 }
  ].freeze

  CURRENCY = '£'
  DISCOUNT = 10

  Product = Struct.new(:code, :name, :price, :quantity, :total_price)
  Rule = Struct.new(:code, :strategy)

  def initialize(pricing_rules)
    raise 'Invalid strategy name!' if invalid_strategy?(pricing_rules)

    @pricing_rules = pricing_rules.map { |pr| Rule.new(**pr) }
  end

  def scan(item)
    return 'Invalid item!' if invalid_item?(item)

    target = products.select { |p| p[:code] == item[:code] }.first
    target ? (target[:quantity] += 1) : "Product with the code #{item[:code]} is out of stock"
  end

  def total
    amount = [buy_one_get_one_free_total, discount_after_third_total, full_price_total].map do |el|
      el.sum { |h| h[:total_price] }
    end.sum
    "#{CURRENCY}#{amount}"
  end

  private

  def invalid_strategy?(pricing_rules)
    current_strategies = pricing_rules.keys.uniq
    !current_strategies.empty? && (current_strategies - %w[buy_one_get_one_free discount_after_third]).empty?
  end

  def invalid_item?(item)
    !item.is_a?(Hash) || item[:code].nil?
  end

  def products
    @products ||= PRODUCTS.map do |p|
      Product.new(*p.merge(quantity: 0, total_price: 0).values)
    end
  end

  def buy_one_get_one_free_total
    target_products(:buy_one_get_one_free).each do |product|
      quantity = product[:quantity]
      next if quantity.zero?

      product[:total_price] = if quantity <= 2
                                product[:price]
                              else
                                [(quantity / 2), (quantity % 2)].sum * product[:price]
                              end
    end
  end

  def discount_after_third_total
    target_products(:discount_after_third).each do |product|
      quantity = product[:quantity]
      next if quantity.zero?

      regular_price = (quantity * product[:price]).to_f
      product[:total_price] = if quantity < 3
                                regular_price
                              else
                                regular_price - (regular_price * DISCOUNT / 100)
                              end
    end
  end

  def full_price_total
    target_products.each do |product|
      quantity = product[:quantity]
      next if quantity.zero?

      product[:total_price] = (quantity * product[:price]).to_f
    end
  end

  def target_products(strategy = nil)
    if strategy
      products.select { |p| p[:code] == pricing_rules[strategy] }
    else
      products - target_products(:buy_one_get_one_free) - target_products(:discount_after_third)
    end
  end
end
