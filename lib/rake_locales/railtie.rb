require 'rake_locales'
require 'rails'

module RakeLocales
  class Railtie < Rails::Railtie
    railtie_name :rake_locales

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end