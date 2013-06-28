require 'jasmine'

namespace :jasmine do
  task :server do
    port = ENV['JASMINE_PORT'] || 8888
    jasmine_yml = ENV['JASMINE_YML'] || 'jasmine.yml'
    Jasmine.load_configuration_from_yaml(File.join(Dir.pwd, 'spec', 'support', jasmine_yml))

    config = Jasmine.config
    server = Jasmine::Server.new(port, Jasmine::Application.app(config))

    puts "your tests are here:"
    puts "  http://localhost:#{port}/"

    server.start
  end
end

desc "Run specs via server"
task :jasmine => ['jasmine:server']
