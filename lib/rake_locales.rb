# frozen_string_literal: true

require_relative "rake_locales/version"

module RakeLocales
  class Error < StandardError; end
  require 'rake_locales/railtie' if defined?(Rails)
end