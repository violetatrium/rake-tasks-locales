# require 'dotenv/load'

require 'uri'
require 'byebug'

module MinimLocales
  module TransifexHelper
    class << self
      def get_translated_strings(locale)
        puts "Fetching latest translations from Transifex for locale: #{locale}"
        translations = {}

        start = "https://rest.api.transifex.com/resource_translations?filter[resource]=o:#{ENV['TRANSLATE_ORG']}:p:#{ENV['TRANSLATE_PROJECT']}:r:#{ENV['TRANSLATE_RESOURCE']}&filter[language]=l:#{format_locale(locale)}"

        uri = URI(start)
        
        while uri
          req = Net::HTTP::Get.new(uri)
          req['Authorization'] = "Bearer #{ENV['TRANSIFEX_BEARER_TOKEN']}"
          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme =='https') { |http|
            http.request(req)
          }
          transifex_json = JSON.parse(res.body)
          byebug
          transifex_json['data'].each { |t| translations[t.dig("relationships", "resource_string", "data", "id").match(/:s:(.*)$/)[1]] = t.dig('attributes', 'strings', 'other') }
          begin
            uri = URI(transifex_json['links']['next'])
          rescue
            uri = nil
          end
        end

        translations
      end

      def format_locale(locale)
        # Transifex has locales in the following format: en_US
        # as opposed to the format we use internally: en-US
        locale.to_s.sub('-', '_')
      end

      # Transifex uses the MD5 hash of the path as a resource strings identifier.
      # NOTE: Transifex combines the path with the context of the string. If we begin adding contexts to resource strings, this will not work.
      def translation_path(path)
        path_key = path.join('.')
        Digest::MD5.hexdigest([path_key, ''].join(':'))
      end

    end
  end
end
