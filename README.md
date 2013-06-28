# Parser

JavaScript class for parsing strings into objects.

## Simple example

    var parser = new Parser();
    parser.parse("foo[bar:baz], boss:niels") => { foo: { bar: 'baz' }, boss: 'niels' }

## Setting default values

Default values can be set when instantiating the class.

    var parser = new Parser({ foo: 'bar' });
    parser.parse("foo") => { foo: 'bar' }

Or afterwards

    var parser = new Parser();
    parser.addDefaultValue('foo', 'bar');
    parser.parse("foo") => { foo: 'bar' }

## Additional parsing features

- The boolean values will get parsed from strings into actual booleans.
- Integers will get parsed as well.

## How to use it

Simply include src/parser.js somewhere on the page.

## Running the test suite

1. Install the dependencies with `bundle install`.
2. Run the suite with `rake jasmine` from within the project root.
3. To go `http://localhost:8888/`
