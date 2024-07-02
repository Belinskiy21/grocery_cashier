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

  Product = Struct.new(:code, :name, :price, :quantity, :total_price, :min_quantity, :discount, keyword_init: true)
  Rule = Struct.new(:min_quantity, :discount, :codes, keyword_init: true)

  def initialize(pricing_rules)
    @pricing_rules = pricing_rules.map { |pr| Rule.new(pr) }
    assign_discounts_to_products
  end

  def scan(item)
    return 'Invalid item!' if item.to_s.empty?

    product = products.find { |p| p.code == item }
    product ? (product.quantity += 1) : "Product with the code #{item} is out of stock"
  end

  def total
    calculate_products_total
    amount = products.sum(&:total_price)
    CURRENCY << amount.to_s
  end

  private

  def products
    @products ||= PRODUCTS.map do |p|
      Product.new(p.merge(quantity: 0, total_price: 0, min_quantity: 0, discount: 0))
    end
  end

  def assign_discounts_to_products
    pricing_rules.each do |pricing_rule|
      pricing_rule.codes.each do |code|
        product = products.find { |p| p.code == code }
        product.min_quantity = pricing_rule.min_quantity
        product.discount = pricing_rule.discount
      end
    end
  end

  def calculate_products_total
    products.each do |product|
      next if product.quantity.zero?

      full_price = (product.quantity * product.price)
      product.total_price = if no_discount?(product)
                              full_price
                            else
                              full_price - (full_price * product.discount / 100)
                            end
    end
  end

  def no_discount?(product)
    !product.discount.zero? || product.quantity < product.min_quantity
  end
end
