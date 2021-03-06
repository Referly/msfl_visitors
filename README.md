[![Circle CI](https://circleci.com/gh/Referly/msfl_visitors.svg?style=svg)](https://circleci.com/gh/Referly/msfl_visitors)

# msfl_visitors
A visitor pattern based approach for converting MSFL to other forms

## Usage

```ruby
require 'msfl'

# Load one of the test datasets
require 'msfl/datasets/car'

require 'msfl_visitors'

filter    = { make: "Toyota" }

dataset   = MSFL::Datasets::Car.new

MSFLVisitors.get_chewy_clauses dataset, filter

=> [{:clause=>"make == \"Toyota\""}]

```

## Faceted example

```ruby
require 'msfl'
# Load one of the test datasets
require 'msfl/datasets/car'
require 'msfl_visitors'

filter    = { partial: { given: { make: "Toyota" }, filter: { avg_age: 10 } } }

dataset   = MSFL::Datasets::Car.new

MSFLVisitors.get_chewy_clauses dataset, filter

=> [{:clause=>{:agg_field_name=>:avg_age, :operator=>:eq, :test_value=>10}, :method_to_execute=>:aggregations}, {:clause=>"make == \"Toyota\""}]

```

## An example of a Foreign

```ruby
require 'msfl'
# Load one of the test datasets
require 'msfl/datasets/car'
require 'msfl_visitors'

filter    = { foreign: { dataset: 'person', filter: { gender: 'female' } } }

dataset   = MSFL::Datasets::Car.new

MSFLVisitors.get_chewy_clauses dataset, filter

=> [{:clause=>"has_child( :person ).filter { gender == \"female\" }"}]

```

## An example in which a Foreign is nested in the Given of a Partial
```ruby
require 'msfl'
# Load one of the test datasets
require 'msfl/datasets/car'
require 'msfl_visitors'
# Given the set of cars where the person that is the owner is male, filter the set to only include those cars that
# were manufactured in 2010
filter    = { partial: { given: { foreign: { dataset: 'person', filter: { gender: 'male' } } }, filter: { year: '2010' } } }

dataset   = MSFL::Datasets::Car.new

MSFLVisitors.get_chewy_clauses dataset, filter

=> [{:clause=>{:agg_field_name=>:year, :operator=>:eq, :test_value=>"2010"}, :method_to_execute=>:aggregations}, 
    {:clause=>"has_child( :person ).filter { gender == \"male\" }"}]

```

## Architecture

msfl_visitors is designed to consume normalized Mattermark Semantic Filter Language (NMSFL).
msfl_visitors implements a parser (parsers/msfl_parser) that converts NMSFL into an AST.
msfl_visitors implements a visitor that traverses the ast and produces the well formed output.
The behavior of the visitor is controlled through composition at construction. It accepts a collector and a renderer.

## MSFLParser

The parser accepts a Hash containing NMSFL and produces an AST.
The parser uses a simplified version of the visitor pattern to traverse the NMSFL and produce the AST.

Typically one does not interact with the parser directly, instead a consumer of this gem should interact with the AST.

## AST

The abstract syntax tree that represents a certain query filter. In the version of the visitor pattern herein
adopted, each node of the AST is responsible for managing its state and traversal of itself and children.

A consumer of this gem creates a new AST instance passing in a Hash of NMSFL. The AST will leverage the MSFL parser
to construct itself. The AST object is a Node as it implements the #accept(visitor) method.

## visitor

Unlike the classical visitor pattern double dispatch is not strictly achieved through type matching in the visitor.
Instead the visitor is just a single service that is composed of a collector and a renderer.
The double dispatch is codified inside of a renderer, which like the visitors in the classic pattern can produce
multiple output DSLs.

## collector

Removed as of 0.3

## renderer

Removed as of 0.3