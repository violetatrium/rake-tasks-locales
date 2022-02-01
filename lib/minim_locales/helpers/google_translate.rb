require "google/cloud/translate/v2"

module MinimLocales
  module GoogleTranslateHelper
    class << self
      def get_translation(str, locale)
        # replace i18n vars with uuid
        initial = []
        vars = []

        processed = str.gsub(/%\{.+?\}/) do |s|
          new_key = "temp_18n_machine_key_#{initial.length}"
          vars.push(new_key)
          initial.push(s)
          new_key
        end

        translated = translate_string(processed, google_locale(locale))
        initial.each_with_index do |init, i|
          translated.gsub!(/#{vars[i]}/, init)
        end

        translated
      end

      def translate_string(string, locale)
        translate = Google::Cloud::Translate::V2.new
        translate.translate(string, to: locale).text
      end

      def google_locale(locale)
        locale.to_s.gsub(/[\-_].*/, '')
      end

    end
  end
end
