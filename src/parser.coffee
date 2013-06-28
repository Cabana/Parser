Array::clean = (deleteValue) ->
  i = 0
  while i < @length
    if this[i] is deleteValue
      @splice i, 1
      i--
    i++
  this

String::wrapInBraces = ->
  @.replace(/^/, '{').replace(/$/, '}')
String::replaceSquareBracketsWithBraces = ->
  @.replace(/\[/g, '{').replace(/\]/g, '}')
String::removeWhitespace = ->
  @.replace(/\s+/g, '')

class @Parser
  constructor: (defaults) ->
    @defaults = defaults

  parse: (string) ->
    result = {}

    return result if string == ''

    string = @_prepareString string
    @_toJSON string

  addDefaultValue: (value, key) ->
    @defaults ||= {}
    @defaults[value] = key

  _prepareString: (string) ->
    string = string.removeWhitespace()
    string = @_applyOptionValues string if @defaults
    string = @_setUndefinedValues string
    string = @_wrapWordsInQuotes string
    string

  _applyOptionValues: (string) ->
    newString = ''

    splitString = @_splitIntoWords string

    splitString.forEach (word, index) =>
      nextWord = splitString[index + 1]
      if @defaults[word] && nextWord != ':'
        word += ":#{@defaults[word]}"
      newString += word

    newString

  _setUndefinedValues: (string) ->
    splitString = @_splitIntoWords string

    # add undefined at the keys that have no value
    splitString.forEach (word, index) ->
      nextWord = splitString[index + 1]
      prevWord = splitString[index - 1]
      if /\]+/.test(nextWord) && prevWord != ':' || nextWord == ',' || nextWord == undefined && !/\]+/.test(word)
          splitString[index] += ":undefined"
    string = splitString.join ''

    # remove the undefineds that were too many
    newString = ''
    string.split(/(\[|,|\])/).forEach (string) ->
      if /.*:.*:.*/.test string
        string = string.replace ':undefined', ''
      newString += string

    newString

  _splitIntoWords: (string) ->
    string.split(/(\w+)/).clean('')
    string.split(/(:\[?|\]+,?|,)/).clean('')

  _wrapWordsInQuotes: (string) ->
    splitString = @_splitIntoWords string

    splitString.forEach (word, index) ->
      unless word == ':' || /\]+/.test(word) || word == ':[' || word == ','
        if /^\d+$/.test word
          splitString[index] = parseInt word
        else if word == 'true'
          splitString[index] = true
        else if word == 'false'
          splitString[index] = false
        else
          splitString[index] = "\"#{word}\""

    splitString.join ''

  _toJSON: (string) ->
    string += ":\"undefined\"" unless /\.*:\.*/.test string

    string = string.replaceSquareBracketsWithBraces().wrapInBraces()
    string = string.replace /\\/g, "\\\\"
    JSON.parse string
