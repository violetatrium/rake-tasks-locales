# frozen_string_literal: true

require 'digest'
require 'json'

require_relative "minim_locales/helpers/google_translate"
require_relative "minim_locales/helpers/transifex"
require_relative "minim_locales/version"

module MinimLocales
  class Error < StandardError; end

  require 'minim_locales/railtie' if defined?(Rails)

  class << self
    def update
      update_intermediate_locales
      update_public_locales
      transifex_export
    end

    # Update databases command

    def update_intermediate_locales
      en_translations = {}

      Dir.glob("#{ENV['PUBLIC_LOCALES_DIRECTORY']}/*en-US.json").each do |en_path|
        new_en_translations = JSON.parse(File.read(en_path))['en-US']

        duplicate_keys = en_translations.keys & new_en_translations.keys
        if duplicate_keys.length > 0
          STDERR.puts('Found duplicate top level keys in the English translation files')
          STDERR.puts('Having duplicate keys could cause some translations to be overwritten')
          STDERR.puts('Detected keys were:')
          STDERR.puts("- #{duplicate_keys.join("\n- ")}")
          exit 1
        end

        en_translations.merge!(new_en_translations)
      end

      ENV['SUPPORTED_LOCALES'].split(',').each do |locale|
        intermediate_file_path = "#{ENV['INTERMEDIATE_LOCALES_DIRECTORY']}/intermediate_#{locale}.json"
        puts "Updating #{intermediate_file_path}"

        if locale == :'en-US'
          File.write(intermediate_file, JSON.pretty_generate(update_or_create_intermediate_database(en_translations, {})))
          next
        end

        intermediate_db = nil

        if File.exist?(intermediate_file_path)
          intermediate_db = JSON.parse(File.read(intermediate_file_path))
          intermediate_db = update_or_create_intermediate_database(en_translations, intermediate_db)
        else
          locale_translations = {}

          Dir.glob("#{ENV['PUBLIC_LOCALES_DIRECTORY']}/*#{locale}.json").each do |locale_path|
            locale_translations.merge!(JSON.parse(File.read(locale_path))[locale.to_s])
          end

          intermediate_db = update_or_create_intermediate_database(en_translations, locale_translations)
        end

        File.write(intermediate_file_path, JSON.pretty_generate(intermediate_db))
      end
    end

    def update_or_create_intermediate_database(en, locale)
      if en.is_a?(String)
        generate_intermediate_data(en, locale)
      else
        Hash[*en.flat_map { |k, v| [k, update_or_create_intermediate_database(v, locale&.dig(k))] }]
      end
    end

    def generate_intermediate_data(en, locale)
      if locale.nil?
        { 'text' => en, 'en_hash' => Digest::SHA1.hexdigest(en), 'status' => 'english' }
      elsif locale.is_a?(String)
        { 'text' => locale, 'en_hash' => Digest::SHA1.hexdigest(en), 'status' => 'reviewed' }
      elsif locale['en_hash'] == Digest::SHA1.hexdigest(en)
        locale
      else
        locale.merge('status' => 'modified', 'text' => en)
      end
    end

    # Update public locales command

    def update_public_locales
      ENV['SUPPORTED_LOCALES'].split(',').each do |locale|
        next if locale == 'en-US'

        intermediate_file = "#{ENV['INTERMEDIATE_LOCALES_DIRECTORY']}/intermediate_#{locale}.json"
        locale_file = "#{ENV['PUBLIC_LOCALES_DIRECTORY']}/#{locale}.json"

        if File.exist?(intermediate_file)
          locale_db = JSON.parse(File.read(intermediate_file))
          translations = TransifexHelper.get_translated_strings(locale)

          l = get_paths("text", locale_db) do  |v|
            v['status'] != 'reviewed'
          end

          l.each do |path|
            translation = translations[TransifexHelper.translation_path(path)]
            i18n_obj = locale_db.dig(*path)

            if translation
              i18n_obj['text'] = translation
              i18n_obj['status'] = 'reviewed'
            elsif i18n_obj['status'] != 'machine'
              machine_translation = GoogleTranslateHelper.get_translation(locale_db.dig(*path)['text'], locale)
              i18n_obj['text'] = machine_translation
              i18n_obj['status'] = 'machine'
            end
          end

          File.write(intermediate_file, JSON.pretty_generate(locale_db))

          get_paths('text', locale_db).each do |path|
            deep_set(locale_db, locale_db.dig(*path)['text'], *path)
          end

          File.write(locale_file, JSON.pretty_generate({ "#{locale}": locale_db }))
        end
      end
    end

    # gets the path for a key.
    # optionally accepts a block as a condition for checking the status of a translation
    # defaults to getting all the paths
    def get_paths(key, intermediate_db, &block)
      intermediate_db.flat_map do |k, v|
        next unless v.kind_of?(Hash)

        condition = block ? yield(v) : true
        if v.key?(key) && condition
          [[k]]
        else
          get_paths(key, v, &block).map{|a| a.unshift(k)}
        end
      end.compact
    end

    def deep_set(hash, value, *keys)
      keys[0...-1].inject(hash) do |acc, h|
        acc.public_send(:[], h)
      end.public_send(:[]=, keys.last, value)
    end

    # Transifex export command

    def transifex_export
      locale = 'en-US'
      intermediate_file_path = "#{ENV['INTERMEDIATE_LOCALES_DIRECTORY']}/intermediate_#{locale}.json"

      puts "Uploading #{locale} to transifex for translating"

      if File.exist?(intermediate_file_path)
        intermediate_db = JSON.parse(File.read(intermediate_file_path))

        transifex_file = "#{ENV['INTERMEDIATE_LOCALES_DIRECTORY']}/transifex_#{locale}.json"
        File.write(transifex_file, JSON.pretty_generate(prepare_intermediates_for_export(intermediate_db)))

        puts "#{ENV['INTERMEDIATE_LOCALES_DIRECTORY']}/transifex_#{locale}.json"
        puts "DONE, SMOKED EM"
        puts "SHEEEEESH"
      else
        STDERR.puts("Intermediate file for #{locale} does not exist!")
        STDERR.puts("Run the update_intermediates command to generate it")
        STDERR.puts("Aborting!")
        exit 1
      end

      # upload_url = "https://www.transifex.com/api/2/project/#{ENV['TRANSLATE_PROJECT']}/resource/#{ENV['TRANSLATE_RESOURCE']}/content/"

      # cmd = "curl -i -L --user api:#{ENV['TRANSIFEX_BEARER_TOKEN']} -F file=@#{transifex_file} -X PUT #{upload_url}"
      if system(cmd)
        puts "Successfully uploaded transifex db"
      else
        puts "Failed to upload"
      end
    end

    def prepare_intermediates_for_export(locale)
      if locale.key?("en_hash")
        case locale['status']
        when 'english'
          { 'string' => locale['text'] }
        when 'modified'
          { 'string' => locale['new_text'] }
        else
          nil
        end
      else
        hash = Hash[*locale.flat_map { |k, v| [k, prepare_intermediates_for_export(v)] }].compact
        hash.keys.length > 0 ? hash : nil
      end
    end

    # Verify command

    def verify
      ENV['SUPPORTED_LOCALES'].split(',') do |locale|
        puts "Verifying #{locale}"

        intermediate_file_path = "#{ENV['INTERMEDIATE_LOCALES_DIRECTORY']}/intermediate_#{locale}.json"
        locale_file = "#{ENV['PUBLIC_LOCALES_DIRECTORY']}/#{locale}.json"

        eng_found = false
        File.open(intermediate_file_path) do |file|
          eng_found = file.find { |line| line.match?(/status.*(english|modified)/) }
        end

        if eng_found
          puts "String with english status found in #{intermediate_file_path}"
          puts "#{ENV['TRANSLATE_HELP_MESSAGE']}"
          exit(1)
        end

        intermediate_db = JSON.parse(File.read(intermediate_file_path))
        locale_strings = get_curr_locale_strings(locale_file)
        intermediate_strings = get_paths('text', intermediate_db).map { |path| intermediate_db.dig(*path)['text'] }

        unless intermediate_strings.sort == locale_strings.sort
          puts 'Intermediate strings and public strings don\'t match.'
          puts "#{ENV['TRANSLATE_HELP_MESSAGE']}"
          exit(1)
        end
      end
    end

    def get_curr_locale_strings(filename)
      locale_hash = JSON.parse(File.read(filename))

      get_values_from_hash(locale_hash)
    end

    def get_values_from_hash(h)
      strings = []

      h.each_value do |value|
        value.is_a?(Hash) ? get_values_from_hash(value).each{|l| strings << l } : strings << value
      end

      strings
    end

  end
end