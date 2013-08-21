# Parser

JavaScript class for parsing strings into objects.

## Simple example

```javascript
var parser = new Parser();
parser.parse("foo[bar:baz], boss:niels") // => { foo: { bar: 'baz' }, boss: 'niels' }
```

## Setting default values

Default values can be set when instantiating the class.

```javascript
var parser = new Parser({ foo: 'bar' });
parser.parse("foo") // => { foo: 'bar' }
```

Or afterwards

```javascript
var parser = new Parser();
parser.addDefaultValue('foo', 'bar');
parser.parse("foo") // => { foo: 'bar' }
```

## Additional parsing features

- The boolean values will get parsed from strings into actual booleans.
- Integers will get parsed as well.

## How to use it

Simply include build/parser.js somewhere on the page.

## Running the test suite

1. Clone down the repo.
2. Install the dependencies with `bundle install` from within the project root.
3. Setup [karma](http://karma-runner.github.io/)
4. Run `karma start`
