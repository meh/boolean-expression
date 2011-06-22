boolean-expression, a simple boolean expression parser/evaluator
================================================================

This gem is used in packø, needed to check tag filters in non-relational databases.

Simple example:

```ruby
require 'boolean/expression'

Boolean::Expression['something || something-else'][:something]  # => true
Boolean::Expression['something && something-else'][:something]  # => false
Boolean::Expression['something && !something-else'][:something] # => true
```

You can also use more complex expression with parenthesis and NOT operators.
