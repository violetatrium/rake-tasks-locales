require_relative '../minim_locales'

namespace :locales do
  task :update do
    MinimLocales.update
  end

  task :update_intermediate_locales do
    MinimLocales.update_intermediate_locales
  end

  taks :update_public_locales do
    MinimLocales.update_public_locales
  end

  taks :transifex_export do
    MinimLocales.transifex_export
  end

  taks :verify do
    MinimLocales.verify
  end
end
