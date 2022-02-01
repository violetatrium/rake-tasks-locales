# frozen_string_literal: true

require_relative "minim_locales/version"

module MinimLocales
  class Error < StandardError; end
  require 'minim_locales/railtie' if defined?(Rails)
end