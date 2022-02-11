require_relative '../minim_locales'

namespace :locales do
  task :update do
    # MinimLocales.update
    puts 'update'
  end

  task :update_intermediate_locales do
    # MinimLocales.update_intermediate_locales
    puts 'update_intermediate_locales'
  end

  taks :update_public_locales do
    # MinimLocales.update_public_locales
    puts 'update_public_locales'
  end

  taks :transifex_export do
    # MinimLocales.transifex_export
    puts 'transifex_export'
  end

  taks :verify do
    # MinimLocales.verify
    puts 'verify'
  end
end
