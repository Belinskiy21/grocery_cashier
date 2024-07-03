# The Grocery Cashier function:

  Allows to add products to the customer basket and calculate the total price of the basket.

## The correc format of pricing rules:

* type (array of objects)
* example:

  ``` ruby
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
  ```

* `min_quantity`(number) - is a quantity when the discount will be applied
* `discount` (number) - discount to assign in percentage(%)
* `codes` (array of strings) - collection of products codes to assight the rule

## Run tests:

``` bash
   bundle i
   bundle exec rspec spec

```
