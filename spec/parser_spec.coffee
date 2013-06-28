describe 'String', ->
  describe '#wrapInBraces', ->
    it 'should wrap the string in braces', ->
      expect( 'foo'.wrapInBraces() ).toBe '{foo}'

  describe '#replaceSquareBracketsWithBraces', ->
    it 'replace all square brackets with braces', ->
      expect( '[foo]'.replaceSquareBracketsWithBraces() ).toBe '{foo}'

  describe '#removeWhitespace', ->
    it 'removes all whitespace from a string', ->
      expect( 'foo bar'.removeWhitespace() ).toBe 'foobar'

describe 'Parser', ->
  describe 'without default values', ->
    beforeEach ->
      @parser = new Parser

    it 'parses an empty string into an empty object', ->
      expect( @parser.parse '' ).toEqual {}

    it 'parses a single key:value pair', ->
      expect( @parser.parse 'key:value' ).toEqual { key: 'value' }

    it 'parses multiple key:value pairs', ->
      expect( @parser.parse 'foo:value, bar:value' ).toEqual { foo: 'value', bar: 'value' }

    it 'parses nested key:value pairs', ->
      expect( @parser.parse 'foo:[bar:value]' ).toEqual { foo: { bar: 'value' } }

    it 'parses nested key:value pairs along with simple pairs', ->
      expect( @parser.parse 'foo:[bar:value], test:mega' ).toEqual { foo: { bar: 'value' }, test: 'mega' }

    it 'parses multiple nested pairs', ->
      expect( @parser.parse 'foo:[bar:value], foo:[bar:value]' ).toEqual { foo: { bar: 'value' }, foo: { bar: 'value' } }

    it 'parses pairs with multiple levels of nesting', ->
      expect( @parser.parse 'foo:[bar:[test:mega]]' ).toEqual { foo: { bar: { test: 'mega' } } }

    it 'parses nested pairs alongside simple pairs', ->
      expect( @parser.parse 'foo:[bar:value], test:mega' ).toEqual { foo: { bar: 'value' }, test: 'mega' }

    it 'converts integers', ->
      expect( @parser.parse 'foo:1' ).toEqual { foo: 1 }
      expect( @parser.parse 'foo:88' ).toEqual { foo: 88 }
      expect( @parser.parse 'foo:foo1' ).toEqual { foo: 'foo1' }

    it 'converts booleans', ->
      expect( @parser.parse 'foo:true' ).toEqual { foo: true }
      expect( @parser.parse 'foo:false' ).toEqual { foo: false }

    it 'parses undefined values', ->
      expect( @parser.parse 'key' ).toEqual { key: 'undefined' }

    it 'parses multiple undefined values', ->
      expect( @parser.parse 'foo, bar' ).toEqual { foo: 'undefined', bar: 'undefined' }

    it 'parses nested undefined values', ->
      expect( @parser.parse 'foo:[bar]' ).toEqual { foo: { bar: 'undefined' } }

    it 'also parses then a value is kinda funky', ->
      expect( @parser.parse 'foo:.+' ).toEqual { foo: '.+' }
      expect( @parser.parse 'foo:.+@.+\..+' ).toEqual { foo: '.+@.+\..+' }
      expect( @parser.parse 'foo:\\d{8}' ).toEqual { foo: '\\d{8}' }

    it 'can be used to generate a regex', ->
      regex = new RegExp @parser.parse("foo:\\d{8}").foo
      expect( regex.test '12345678' ).toBe true

    it 'parses a slightly more complex string', ->
      string = 'format:[email, custom:[cpr:\\d{6}-\\d{4}], required:.+], length:[min:3, max:255], allowEmpty: true'
      result = {
        format: {
          email: 'undefined',
          custom: {
            cpr: '\\d{6}-\\d{4}'
          },
          required: '.+'
        },
        length: {
          min: 3,
          max: 255
        },
        allowEmpty: true
      }
      expect( @parser.parse string ).toEqual result

  describe 'with default values', ->
    describe 'added upon instantiation', ->
      it 'parses with default values', ->
        parser = new Parser({ foo: 'bar' })
        expect( parser.parse 'foo' ).toEqual { foo: 'bar' }

      it 'parses with multiple default values', ->
        parser = new Parser({ foo: 'bar', bar: 'booz' })
        expect( parser.parse 'foo, bar' ).toEqual { foo: 'bar', bar: 'booz' }

      it 'does not overwrite values given in the string', ->
        parser = new Parser({ foo: 'bar' })
        expect( parser.parse 'foo:mads' ).toEqual { foo: 'mads' }

      it 'parses nested values with default values', ->
        parser = new Parser({ bar: 'baz' })
        expect( parser.parse 'foo:[bar]' ).toEqual { foo: { bar: 'baz' } }

      it 'parses with multiple values where some of them have nested values', ->
        parser = new Parser({ bar: 'baz', two: 'mads' })
        expect( parser.parse 'one:[bar], two' ).toEqual { one: { bar: 'baz' }, two: 'mads' }

      it 'parses multiple levels deep', ->
        parser = new Parser({ bar: 'baz', three: 'mads' })
        expect( parser.parse 'one:[bar, two:[three]]' ).toEqual {
          one: {
            bar: 'baz',
            two: {
              three: 'mads'
            }
          }
        }

      it 'only adds values where they need to be', ->
        parser = new Parser({ foo: 'foo' })
        expect( parser.parse 'foo, bar' ).toEqual { foo: 'foo', bar: 'undefined' }
        expect( parser.parse 'bar, foo' ).toEqual { bar: 'undefined', foo: 'foo' }

    describe 'adding default values after instantiation', ->
      describe '#addDefaultValue', ->
        it 'parses with the new default value', ->
          parser = new Parser
          parser.addDefaultValue 'foo', 'bar'
          expect( parser.parse 'foo' ).toEqual { foo: 'bar' }

        it 'still works with value defined upon instantiation', ->
          parser = new Parser({ foo: 'bar' })
          parser.addDefaultValue 'baz', 'booz'
          expect( parser.parse 'foo, baz' ).toEqual { foo: 'bar', baz: 'booz' }

  describe 'a real world example', ->
    beforeEach ->
      @parser = new Parser({
        email: '.+@.+\\..+'
      })
      @parser.addDefaultValue 'cpr', '\\d{6}-\\d{4}'
      @string = 'format:[email, custom:[cpr]], length:[min:3, max:255], allowEmpty: true'
      @result = {
        format: {
          email: '.+@.+\\..+',
          custom: {
            cpr: '\\d{6}-\\d{4}'
          }
        },
        length: {
          min: 3,
          max: 255
        },
        allowEmpty: true
      }

    it 'parses it', ->
      expect( @parser.parse @string ).toEqual @result

    describe 'the result', ->
      it 'can be used to do regex matching', ->
        regex = new RegExp @result.format.email
        expect( regex.test('david.pdrsn@gmail.com') ).toEqual true
