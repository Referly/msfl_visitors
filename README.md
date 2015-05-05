[![Circle CI](https://circleci.com/gh/Referly/msfl_visitors.svg?style=svg)](https://circleci.com/gh/Referly/msfl-visitors)

# msfl_visitors
A visitor pattern based approach for converting MSFL to other forms

## Architecture

msfl_visitors is designed to consume normalized Mattermark Semantic Filter Language (NMSFL). msfl_visitors implements a parser (parsers/msfl_parser) that converts NMSFL into an AST. msfl_visitors implements a visitor that traverses the ast and produces the well formed output. The visitor is composable during construction, it accepts a collector and a renderer. 

## MSFLParser

The parser accepts a Hash containing NMSFL and produces an AST. The parser uses a simplified version of the visitor pattern to traverse the NMSFL and produce the AST.

## ast

## visitor

## collector

## renderer
