require 'spec_helper'

describe MSFLVisitors::Visitor do

  let(:node) { fail ArgumentError, "You must define the node variable in each scope." }

  let(:visitor) { described_class.new }

  let(:left) { MSFLVisitors::Nodes::Field.new "lhs" }

  let(:right) { MSFLVisitors::Nodes::Word.new "rhs" }

  subject(:result) { node.accept visitor }

  context "when visiting" do

    describe "an unsupported node" do

      class UnsupportedNode

        def accept(visitor)
          visitor.visit self
        end
      end

      let(:node) { UnsupportedNode.new }

      context "when using the TermFilter visitor" do

        it "raises an ArgumentError" do
          expect { subject }.to raise_error ArgumentError
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "raises an ArgumentError" do
          expect { subject }.to raise_error ArgumentError
        end
      end

    end

    describe "a Partial node" do

      let(:node)                    { MSFLVisitors::Nodes::Partial.new given_node, named_value }

        let(:given_node)              { MSFLVisitors::Nodes::Given.new [given_equal_node] }

          let(:given_equal_node)        { MSFLVisitors::Nodes::Equal.new given_field_node, given_value_node }

          let(:given_field_node)          { MSFLVisitors::Nodes::Field.new :make }

            let(:given_value_node)        { MSFLVisitors::Nodes::Word.new "Toyota" }


      let(:named_value)    { MSFLVisitors::Nodes::NamedValue.new MSFLVisitors::Nodes::Word.new("partial"), explicit_filter_node }

        let(:explicit_filter_node)    { MSFLVisitors::Nodes::ExplicitFilter.new [greater_than_node] }

            let(:greater_than_node)              { MSFLVisitors::Nodes::GreaterThan.new field_node, value_node }

              let(:field_node)              { MSFLVisitors::Nodes::Field.new :age }

              let(:value_node)              { MSFLVisitors::Nodes::Number.new 10 }


      subject { visitor.visit_tree node }

      let(:expected) do
        [{ clause: { agg_field_name: :age, operator: :gt, test_value: 10 }, method_to_execute: :aggregations },
         { clause: "make == \"Toyota\"" }]
      end

      it "results in the appropriate aggregation clause" do
        visitor.mode = :aggregations
        expect(subject).to eq expected
      end

      context "when the Partial node is wrapped in a Filter node" do

        let(:node) { MSFLVisitors::Nodes::Filter.new([MSFLVisitors::Nodes::Partial.new(given_node, named_value)]) }

        it "results in the appropriate aggregation clause" do
          expect(subject).to eq expected
        end
      end
    end

    describe "a Given node" do

      let(:node)                    { MSFLVisitors::Nodes::Given.new [given_equal_node] }

        let(:given_equal_node)        { MSFLVisitors::Nodes::Equal.new given_field_node, given_value_node }

          let(:given_field_node)        { MSFLVisitors::Nodes::Field.new :make }

          let(:given_value_node)        { MSFLVisitors::Nodes::Word.new "Toyota" }


      it "results in: [:filter, { agg_field_name: :make, operator: :eq, test_value: \"Toyota\" }]" do
        visitor.mode = :aggregations
        expect(subject).to eq([:filter, { agg_field_name: :make, operator: :eq, test_value: "Toyota" }])
      end
    end

    describe "a Foreign node" do

      let(:node) { MSFLVisitors::Nodes::Foreign.new dataset_node, filter_node }

      let(:dataset_node) { MSFLVisitors::Nodes::Dataset.new "person" }

      let(:filter_node) { MSFLVisitors::Nodes::ExplicitFilter.new [equal_node] }

      let(:equal_node) { MSFLVisitors::Nodes::Equal.new left, right }

      let(:left) { MSFLVisitors::Nodes::Field.new :age }

      let(:right) { MSFLVisitors::Nodes::Number.new 25 }

      context "when using the TermFilter visitor" do

        it "results in: 'has_child( :person ).filter { age == 25 }" do
          expect(subject).to eq "has_child( :person ).filter { age == 25 }"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { foreign: { type: \"person\", filter: { agg_field_name: :age, operator: :eq, test_value: 25 } } }" do
          expect(subject).to eq({ foreign: { type: "person", filter: { agg_field_name: :age, operator: :eq, test_value: 25 } } })
        end
      end
    end

    describe "a Containment node" do

      let(:node) { MSFLVisitors::Nodes::Containment.new field, values }

      let(:values) { MSFLVisitors::Nodes::Set.new(MSFL::Types::Set.new([item_one, item_two, item_three])) }

      let(:item_one) { MSFLVisitors::Nodes::Word.new "item_one" }

      let(:item_two) { MSFLVisitors::Nodes::Word.new "item_two" }

      let(:item_three) { MSFLVisitors::Nodes::Word.new "item_three" }

      let(:field)  { left }

      context "when using the TermFilter visitor" do

        it "results in: 'lhs == [ \"item_one\", \"item_two\", \"item_three\" ]'" do
          expect(subject).to eq "lhs == [ \"item_one\" , \"item_two\" , \"item_three\" ]"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { agg_field_name: :lhs, operator: :in, test_value: [\"item_one\", \"item_two\", \"item_three\"] }" do

          expect(subject).to eq({ agg_field_name: :lhs, operator: :in, test_value: ["item_one", "item_two", "item_three"] })
        end
      end
    end

    describe "a Set node" do

      let(:node) { MSFLVisitors::Nodes::Set.new values }

      let(:values) { MSFL::Types::Set.new([item_one, item_two]) }

      let(:item_one) { MSFLVisitors::Nodes::Word.new "item_one" }

      let(:item_two) { MSFLVisitors::Nodes::Word.new "item_two" }

      context "when using the TermFilter visitor" do

        it "results in: '[ \"item_one\" , \"item_two\" ]'" do
          expect(result).to eq "[ \"item_one\" , \"item_two\" ]"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: [\"item_one\", \"item_two\"]" do
          expect(result).to eq ["item_one", "item_two"]
        end
      end
    end

    describe "a Regex node" do

      let(:node) { MSFLVisitors::Nodes::Regex.new regex }

      let(:regex) { "foobar" }

      context "when using the TermFilter visitor" do

        it "results in: /.*foobar.*/" do
          expect(result).to eq /.*foobar.*/
        end

        context "when the node requires escaping" do

          let(:node) { MSFLVisitors::Nodes::Regex.new "foo*bar" }

          it "results in: #{/.*foo\*bar.*/.inspect}" do
            expect(result).to eq /.*foo\*bar.*/
          end
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: 'foobar'" do
          expect(result).to eq "foobar"
        end
      end

      context "when the expression contains `#`, `@`, `&`, `<`, `>`, or `~`" do

        let(:regex) { "a #sentence@ contain&ing <lucene> cha~rs" }

        it "escapes lucene specific special characters" do
          expected =  /.*a\ \#sentence\@\ contain\&ing\ \<lucene\>\ cha\~rs.*/
          expect(result).to eq expected
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "escapes lucene specific special characters" do
            expect(result).to eq "a\\ \\#sentence\\@\\ contain\\&ing\\ \\<lucene\\>\\ cha\\~rs"
          end
        end
      end

      context "when the regex contains characters that require escaping" do

        let(:regex) { 'this / needs to % {be,escaped} *. ^[or] | \else' }

        let(:node) { MSFLVisitors::Nodes::Regex.new regex }

        it "returns: #{/.*this\ \/\ needs\ to\ %\ \{be,escaped\}\ \*\.\ \^\[or\]\ \|\ \\else.*/.inspect}" do
          expect(result).to eq /.*this\ \/\ needs\ to\ %\ \{be,escaped\}\ \*\.\ \^\[or\]\ \|\ \\else.*/
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: 'this\\ \\/\\ needs\\ to\\ %\\ \\{be,escaped\\}\\ \\*\\.\\ \\^\\[or\\]\\ \\|\\ \\\\else'" do
            expect(result).to eq "this\\ \\/\\ needs\\ to\\ %\\ \\{be,escaped\\}\\ \\*\\.\\ \\^\\[or\\]\\ \\|\\ \\\\else"
          end
        end
      end
    end

    describe "a Match node" do

      let(:node) { MSFLVisitors::Nodes::Match.new left, right }

      context "when using the TermFilter visitor" do

        it "results in: 'left =~ /.*rhs.*/'" do
          expect(result).to eq %(lhs =~ /.*rhs.*/)
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { agg_field_name: :lhs, operator: :match, test_value: \"rhs\" }" do
          expect(result).to eq({agg_field_name: :lhs, operator: :match, test_value: "rhs"})
        end
      end

      context "when the right hand side is a Value node that requires escaping" do

        let(:right) { MSFLVisitors::Nodes::Word.new 'this (ne&eds) to be* escaped' }

        context "when using the TermFilter visitor" do

          it "results in: 'left =~ /.*this\ \(ne\&eds\)\ to\ be\*\ escaped.*/'" do
            expect(result).to eq %(lhs =~ ) + /.*this\ \(ne\&eds\)\ to\ be\*\ escaped.*/.inspect
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it %(results in: { agg_field_name: :lhs, operator: :match, test_value: "this\\ \\(ne\\&eds\\)\\ to\\ be\\*\\ escaped" }) do
            expected = { agg_field_name: :lhs, operator: :match, test_value: "this\\ \\(ne\\&eds\\)\\ to\\ be\\*\\ escaped" }
            expect(result).to eq expected
          end
        end
      end

      context "when the right hand side is a Set node containing Value nodes" do

        let(:right) { MSFLVisitors::Nodes::Set.new [foo_node, bar_node, baz_node] }

        let(:foo_node) { MSFLVisitors::Nodes::Word.new "foo" }

        let(:bar_node) { MSFLVisitors::Nodes::Word.new "bar" }

        let(:baz_node) { MSFLVisitors::Nodes::Word.new "baz" }

        context "when using the TermFilter visitor" do

          it "results in: 'left =~ /.*(foo|bar|baz).*/'" do
            expect(result).to eq %(lhs =~ ) + /.*(foo|bar|baz).*/.inspect
          end

          context "when one of the members of the Set requires escaping" do

            let(:foo_node) { MSFLVisitors::Nodes::Word.new "please&*escape me" }

            it "escapes special characters" do
              expect(result).to eq %(lhs =~ ) + /.*(please\&\*escape\ me|bar|baz).*/.inspect
            end
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "results in: { agg_field_name: :lhs, operator: :match, test_value: \"(foo|bar|baz)\" }" do
            expect(result).to eq({agg_field_name: :lhs, operator: :match, test_value: "(foo|bar|baz)"})
          end

          context "when one of the members of the Set requires escaping" do

            let(:foo_node) { MSFLVisitors::Nodes::Word.new "please&*escape me" }

            it "results in { agg_field_name: :lhs, operator: :match, test_value: \"(please\\&\\*escape\\ me|bar|baz) }" do
              expected = { agg_field_name: :lhs, operator: :match, test_value: "(please\\&\\*escape\\ me|bar|baz)" }
              expect(result).to eq expected
            end
          end
        end
      end
    end

    describe "an Equal node" do

      let(:node) { MSFLVisitors::Nodes::Equal.new left, right }

      context "when the current visitor is Chewy::TermFilter" do

        it "results in: 'left == right'" do
          expect(result).to eq "lhs == \"rhs\""
        end
      end

      context "when the current visitor is Chewy::Aggregations" do

        before { visitor.mode = :aggregations }

        it "results in: { agg_field_name: :lhs, operator: :eq, test_value: \"rhs\" }" do
          expect(result).to eq({ agg_field_name: :lhs, operator: :eq, test_value: "rhs" })
        end
      end
    end

    describe "a GreaterThan node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThan.new left, right }

      let(:right) { MSFLVisitors::Nodes::Number.new 1000 }

      context "when using the TermFilter visitor" do

        it "returns: 'left > 1000'" do
          expect(result).to eq "lhs > 1000"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { agg_field_name: :lhs, operator: :gt, test_value: 1000 }" do
          expect(result).to eq({ agg_field_name: :lhs, operator: :gt, test_value: 1000 })
        end
      end
    end

    describe "a GreaterThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::GreaterThanEqual.new left, right }

      let(:right) { MSFLVisitors::Nodes::Number.new 10.52 }

      context "when using the TermFilter visitor" do

        it "returns: 'left >= 10.52'" do
          expect(result).to eq "lhs >= 10.52"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "results in: { agg_field_name: :lhs, operator: :gte, test_value: 10.52 }" do
          expect(result).to eq({ agg_field_name: :lhs, operator: :gte, test_value: 10.52 })
        end
      end
    end

    describe "a LessThan node" do

      let(:node) { MSFLVisitors::Nodes::LessThan.new left, right }

      let(:right) { MSFLVisitors::Nodes::Number.new 133.7 }

      context "when using the TermFilter visitor" do

        it "returns: 'left < 133.7'" do
          expect(result).to eq 'lhs < 133.7'
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "returns: { agg_field_name: :lhs, operator: :lt, test_value: 133.7 }" do
          expect(result).to eq({ agg_field_name: :lhs, operator: :lt, test_value: 133.7 })
        end
      end
    end

    describe "a LessThanEqual node" do

      let(:node) { MSFLVisitors::Nodes::LessThanEqual.new left, right }

      let(:right) { MSFLVisitors::Nodes::Date.new Date.today }

      context "when using the TermFilter visitor" do

        it "returns: 'left <= \"#{Date.today}\"'" do
          expect(result).to eq "lhs <= \"#{Date.today}\""
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "returns: { agg_field_name: :lhs, operator: :lte, test_value: \"#{Date.today}\"}" do
          expect(result).to eq({ agg_field_name: :lhs, operator: :lte, test_value: "#{Date.today}"})
        end
      end
    end

    describe "a QueryString node" do

      let(:node) { MSFLVisitors::Nodes::QueryString.new left, right }

      let(:right) { MSFLVisitors::Nodes::Word.new "applesauce" }

      context "when using the TermFilter visitor" do

        it %(returns: 'q(query_string:{default_field:"lhs", query:"applesauce"})') do
          expect(result).to eq %(q(query_string:{default_field:"lhs", query:"applesauce"}))
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it %(returns: { agg_field_name: :lhs, operator: :query_string, test_value:"applesauce") do
          expect(result).to eq({agg_field_name: :lhs, operator: :query_string, test_value: "applesauce"})
        end
      end
    end

    describe "a Filter node" do

      let(:node) { MSFLVisitors::Nodes::Filter.new filtered_nodes }

      let(:filtered_nodes) do
        [
            MSFLVisitors::Nodes::GreaterThanEqual.new(
                MSFLVisitors::Nodes::Field.new(:value),
                MSFLVisitors::Nodes::Number.new(1000))
        ]
      end

      context "when using the TermFilter visitor" do

        it "returns: value >= 1000" do
          expect(result).to eq "value >= 1000"
        end
      end

      context "when using the Aggregations visitor" do

        before { visitor.mode = :aggregations }

        it "returns: { agg_field_name: :value, operator: :gte, test_value: 1000 }" do
          expect(result).to eq({ agg_field_name: :value, operator: :gte, test_value: 1000 })
        end
      end

      context "when the filter has multiple children" do

        let(:filtered_nodes) do
          [
              MSFLVisitors::Nodes::Equal.new(
                  MSFLVisitors::Nodes::Field.new(:make),
                  MSFLVisitors::Nodes::Word.new("Chevy")
              ),
              MSFLVisitors::Nodes::GreaterThanEqual.new(
                  MSFLVisitors::Nodes::Field.new(:value),
                  MSFLVisitors::Nodes::Number.new(1000))
          ]
        end

        context "when using the TermFilter visitor" do

          it "returns: ( make == \"Chevy\" ) & ( value >= 1000 )" do
            expect(result).to eq "( make == \"Chevy\" ) & ( value >= 1000 )"
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: {
              and: [{ agg_field_name: :make, operator: :eq, test_value: \"Chevy\" },
                    { agg_field_name: :value, operator: :gte, test_value: 1000 }]}" do
            expect(result).to eq({
              and: [{ agg_field_name: :make, operator: :eq, test_value: "Chevy" },
                    { agg_field_name: :value, operator: :gte, test_value: 1000 }]})
          end
        end
      end
    end

    describe "an And node" do

      let(:first_field) { MSFLVisitors::Nodes::Field.new "first_field" }

      let(:first_value) { MSFLVisitors::Nodes::Word.new "first_word" }

      let(:first) { MSFLVisitors::Nodes::Equal.new(first_field, first_value) }

      let(:second_field) { MSFLVisitors::Nodes::Field.new "second_field" }

      let(:second_value) { MSFLVisitors::Nodes::Word.new "second_word" }

      let(:second) { MSFLVisitors::Nodes::Equal.new(second_field, second_value) }

      let(:third_field) { MSFLVisitors::Nodes::Field.new "third_field" }

      let(:third_value) { MSFLVisitors::Nodes::Word.new "third_word" }

      let(:third) { MSFLVisitors::Nodes::Equal.new(third_field, third_value) }

      let(:node) { MSFLVisitors::Nodes::And.new(set_node) }

      context "when the And node has zero items" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [] }

        context "when using the TermFilter visitor" do

          it "is empty" do
            expect(result).to be_empty
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [] }" do
            expect(result).to eq({ and: [] })
          end
        end
      end

      context "when the node has one item" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [first] }

        context "when using the TermFilter visitor" do

          it "returns: the item without adding parentheses" do
            expect(result).to eq 'first_field == "first_word"'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [{ agg_field_name: :first_field, operator: :eq, test_value: \"first_word\" }]}" do
            expect(result).to eq({ and: [{ agg_field_name: :first_field, operator: :eq, test_value: "first_word" }]})
          end
        end
      end

      context "when the node has two items" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [first, second] }

        context "when using the TermFilter visitor" do

          it "returns: '( first_field == \"first_word\" ) & ( second_field == \"second_word\" )'" do
            expect(result).to eq '( first_field == "first_word" ) & ( second_field == "second_word" )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: {
              and: [{ agg_field_name: :first_field, operator: :eq, test_value: \"first_word\" },
                    { agg_field_name: :second_field, operator: :eq, test_value: \"second_word\" }
              ]}" do
            expect(result).to eq({
              and: [{ agg_field_name: :first_field, operator: :eq, test_value: "first_word" },
                    { agg_field_name: :second_field, operator: :eq, test_value: "second_word" }
              ]})
          end
        end
      end

      context "when the node has three items" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [first, second, third] }

        context "when using the TermFilter visitor" do

          it "returns: '( first_field == \"first_word\" ) & ( second_field == \"second_word\" ) & ( third_field == \"third_word\" )'" do
            expect(result).to eq '( first_field == "first_word" ) & ( second_field == "second_word" ) & ( third_field == "third_word" )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: {
              and: [{ agg_field_name: :first_field, operator: :eq, test_value: \"first_word\" },
                    { agg_field_name: :second_field, operator: :eq, test_value: \"second_word\"},
                    {agg_field_name: :third_field, operator: :eq, test_value: \"third_word\"}
              ]}" do
            expect(result).to eq({
              and: [{ agg_field_name: :first_field, operator: :eq, test_value: "first_word" },
                    { agg_field_name: :second_field, operator: :eq, test_value: "second_word"},
                    {agg_field_name: :third_field, operator: :eq, test_value: "third_word"}
              ]})
          end
        end
      end

      context "when one of the node's items is a containment node" do

        let(:node) do
          MSFLVisitors::Nodes::And.new(
              MSFLVisitors::Nodes::Set.new(
                  [
                      MSFLVisitors::Nodes::Filter.new(
                          [
                              MSFLVisitors::Nodes::Containment.new(
                                  MSFLVisitors::Nodes::Field.new(:make),
                                  MSFLVisitors::Nodes::Set.new(
                                      [
                                          MSFLVisitors::Nodes::Word.new("Honda"),
                                          MSFLVisitors::Nodes::Word.new("Chevy"),
                                          MSFLVisitors::Nodes::Word.new("Volvo")
                                      ]
                                  )
                              )
                          ]
                      ),
                      MSFLVisitors::Nodes::Filter.new(
                          [
                              MSFLVisitors::Nodes::GreaterThanEqual.new(
                                  MSFLVisitors::Nodes::Field.new(:value),
                                  MSFLVisitors::Nodes::Number.new(1000)
                              )
                          ]
                      )
                  ]
              )
          )
        end

        context "when using the TermFilter visitor" do

          it "returns: '( make == [ \"Honda\" , \"Chevy\" , \"Volvo\" ] ) & ( value >= 1000 )'" do
            expect(result).to eq '( make == [ "Honda" , "Chevy" , "Volvo" ] ) & ( value >= 1000 )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [{ agg_field_name: :make, operator: :in, test_value: [\"Honda\", \"Chevy\", \"Volvo\"] }, { agg_field_name: :value, operator: :gte, test_value: 1000 } }] }" do
            expected = { and: [
                { agg_field_name: :make, operator: :in, test_value: ["Honda", "Chevy", "Volvo"] },
                { agg_field_name: :value, operator: :gte, test_value: 1000}
            ]}
            expect(result).to eq expected
          end
        end
      end
    end

    describe "an Or node" do

      let(:first_field) { MSFLVisitors::Nodes::Field.new "first_field" }

      let(:first_value) { MSFLVisitors::Nodes::Word.new "first_word" }

      let(:first) { MSFLVisitors::Nodes::Equal.new first_field, first_value }

      let(:second_field) { MSFLVisitors::Nodes::Field.new "second_field" }

      let(:second_value) { MSFLVisitors::Nodes::Word.new "second_word" }

      let(:second) { MSFLVisitors::Nodes::Equal.new second_field, second_value }

      let(:third_field) { MSFLVisitors::Nodes::Field.new "third_field" }

      let(:third_value) { MSFLVisitors::Nodes::Word.new "third_word" }

      let(:third) { MSFLVisitors::Nodes::Equal.new third_field, third_value }

      let(:node) { MSFLVisitors::Nodes::Or.new set_node }

      context "when the Or node has zero items" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [] }

        context "when using the TermFilter visitor" do

          it "is empty" do
            expect(result).to be_empty
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { and: [] }" do
            expect(result).to eq({ or: [] })
          end
        end
      end

      context "when the node has one item" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [first] }

        context "when using the TermFilter visitor" do

          it "returns: the item without adding parentheses" do
            expect(result).to eq 'first_field == "first_word"'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { or: [{ agg_field_name: :first_field, operator: :eq, test_value: \"first_word\" }]}" do
            expect(result).to eq({ or: [{ agg_field_name: :first_field, operator: :eq, test_value: "first_word" }]})
          end
        end
      end

      context "when the node has two items" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [first, second] }

        context "when using the TermFilter visitor" do

          it "returns: '( first_field == \"first_word\" ) | ( second_field == \"second_word\" )'" do
            expect(result).to eq '( first_field == "first_word" ) | ( second_field == "second_word" )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: {
              or: [{ agg_field_name: :first_field, operator: :eq, test_value: \"first_word\" },
                    { agg_field_name: :second_field, operator: :eq, test_value: \"second_word\" }
              ]}" do
            expect(result).to eq({
                                     or: [{ agg_field_name: :first_field, operator: :eq, test_value: "first_word" },
                                           { agg_field_name: :second_field, operator: :eq, test_value: "second_word" }
                                     ]})
          end
        end
      end

      context "when the node has three items" do

        let(:set_node) { MSFLVisitors::Nodes::Set.new [first, second, third] }

        context "when using the TermFilter visitor" do

          it "returns: '( first_field == \"first_word\" ) | ( second_field == \"second_word\" ) | ( third_field == \"third_word\" )'" do
            expect(result).to eq '( first_field == "first_word" ) | ( second_field == "second_word" ) | ( third_field == "third_word" )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: {
              or: [{ agg_field_name: :first_field, operator: :eq, test_value: \"first_word\" },
                    { agg_field_name: :second_field, operator: :eq, test_value: \"second_word\"},
                    {agg_field_name: :third_field, operator: :eq, test_value: \"third_word\"}
              ]}" do
            expect(result).to eq({
                                     or: [{ agg_field_name: :first_field, operator: :eq, test_value: "first_word" },
                                           { agg_field_name: :second_field, operator: :eq, test_value: "second_word"},
                                           {agg_field_name: :third_field, operator: :eq, test_value: "third_word"}
                                     ]})
          end
        end
      end

      context "when one of the node's items is a containment node" do

        let(:node) do
          MSFLVisitors::Nodes::Or.new(
              MSFLVisitors::Nodes::Set.new(
                  [
                      MSFLVisitors::Nodes::Filter.new(
                          [
                              MSFLVisitors::Nodes::Containment.new(
                                  MSFLVisitors::Nodes::Field.new(:make),
                                  MSFLVisitors::Nodes::Set.new(
                                      [
                                          MSFLVisitors::Nodes::Word.new("Honda"),
                                          MSFLVisitors::Nodes::Word.new("Chevy"),
                                          MSFLVisitors::Nodes::Word.new("Volvo")
                                      ]
                                  )
                              )
                          ]
                      ),
                      MSFLVisitors::Nodes::Filter.new(
                          [
                              MSFLVisitors::Nodes::GreaterThanEqual.new(
                                  MSFLVisitors::Nodes::Field.new(:value),
                                  MSFLVisitors::Nodes::Number.new(1000)
                              )
                          ]
                      )
                  ]
              )
          )
        end

        context "when using the TermFilter visitor" do

          it "returns: '( make == [ \"Honda\" , \"Chevy\" , \"Volvo\" ] ) | ( value >= 1000 )'" do
            expect(result).to eq '( make == [ "Honda" , "Chevy" , "Volvo" ] ) | ( value >= 1000 )'
          end
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: { or: [{ agg_field_name: :make, operator: :in, test_value: [\"Honda\", \"Chevy\", \"Volvo\"] }, { agg_field_name: :value, operator: :gte, test_value: 1000 } }] }" do
            expected = { or: [
                { agg_field_name: :make, operator: :in, test_value: ["Honda", "Chevy", "Volvo"] },
                { agg_field_name: :value, operator: :gte, test_value: 1000}
            ]}
            expect(result).to eq expected
          end
        end
      end
    end

    describe "value nodes" do
      describe "a Boolean node" do

        let(:node) { MSFLVisitors::Nodes::Boolean.new value }

        subject(:result) { node.accept visitor }

        context "with a value of true" do

          let(:value) { true }

          context "when using the TermFilter visitor" do

            it "returns: true" do
              expect(result).to eq true
            end
          end

          context "when using the Aggregations visitor" do

            before { visitor.mode = :aggregations }

            it "returns: true" do
              expect(result).to eq true
            end
          end
        end

        context "with a value of false" do

          let(:value) { false }

          it "returns: false" do
            expect(result).to eq false
          end

          context "when using the Aggregations visitor" do

            before { visitor.mode = :aggregations }

            it "returns: false" do
              expect(result).to eq false
            end
          end
        end
      end

      describe "a Word node" do

        let(:word) { "node_content" }

        let(:node) { MSFLVisitors::Nodes::Word.new word }

        it "is a double quoted literal string" do
          expect(result).to eq "\"#{word}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the literal string" do
            expect(result).to eq "#{word}"
          end
        end
      end
    end

    describe "range value nodes" do

      subject(:result) { node.accept visitor }

      describe "a Date node" do

        let(:today) { Date.today }

        let(:node) { MSFLVisitors::Nodes::Date.new today }

        it "returns: the date using iso8601 formatting" do
          expect(result).to eq "\"#{today.iso8601}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the date using iso8601 formatting" do
            expect(result).to eq "#{today.iso8601}"
          end
        end
      end

      describe "a Time node" do

        let(:now) { Time.now }

        let(:node) { MSFLVisitors::Nodes::Time.new now }

        it "returns: the time using iso8601 formatting" do
          expect(result).to eq "\"#{now.iso8601}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the date using iso8601 formatting" do
            expect(result).to eq "#{now.iso8601}"
          end
        end
      end

      describe "a DateTime node" do

        let(:now) { DateTime.now }

        let(:node) { MSFLVisitors::Nodes::DateTime.new now }

        it "returns: the date and time using iso8601 formatting" do
          expect(result).to eq "\"#{now.iso8601}\""
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: the date and time using iso8601 formatting" do
            expect(result).to eq "#{now.iso8601}"
          end
        end
      end

      describe "a Number node" do

        let(:number) { 123 }

        let(:node) { MSFLVisitors::Nodes::Number.new number }

        it "returns: 123" do
          expect(result).to eq number
        end

        context "when using the Aggregations visitor" do

          before { visitor.mode = :aggregations }

          it "returns: 123" do
            expect(result).to eq number
          end
        end

        context "when the number is a float" do

          let(:number) { 123.456 }

          it "returns: the number with the same precision" do
            expect(result).to eq number
          end

          context "when using the Aggregations visitor" do

            before { visitor.mode = :aggregations }

            it "returns: the number with the same precision" do
              expect(result).to eq number
            end
          end
        end
      end
    end
  end
end