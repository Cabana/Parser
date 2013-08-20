require 'closure-compiler'
require 'coffee-script'

compiler = Closure::Compiler.new(compilation_level: 'SIMPLE_OPTIMIZATIONS')

files = [
  'src/lib/split.js',
  'src/parser.coffee'
]

js = files.inject '' do |result, js_component|
  result += if js_component =~ /.*\.coffee$/
              CoffeeScript.compile File.read(js_component)
            else
              File.read(js_component)
            end
end

contents = compiler.compile js

File.open 'build/parser.js', "w" do |file|
  file.write contents
end
