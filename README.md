# RakeLocales

Ruby gem compiling all of the tasks used for localization of our projects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minim_locales'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install minim_locales

## Usage

Below is a list of commands you can run through the use of the `minim_locales` gem. Make sure you have pulled from the recent version of `master` branch before running `rake locales:update`.

```
bundle exec minim_locales update
```
Runs all of the steps needed to update the translation files.

```
bundle exec minim_locales update_intermediate_locales
```
Generates an initial locale database for a new locale entry

```
bundle exec minim_locales update_public_locales
```
Downloads the transifex database and update the public locales.

```
bundle exec minim_locales transfiex_export
```
Generates locale files that are ready to be translated by transifex.

```
bundle exec minim_locales verify
```
Verifies whether or not there are translation files that do not match or if there are English files that have not uet been translated. Prompts the user to run `rake locales:update`

## Environment variables

This gem needs number of environment variables to be set to function correctly. You can see them all listed in the table below:

| Key           | Value    |
|---------------|----------|
| PUBLIC_LOCALES_DIRECTORY | Path to a directory which will contain all of the public locale files (i.e. the files you want to be served to users) for the project you are using the gem in. |
| INTERMEDIATE_LOCALES_DIRECTORY | Path to a directory which will contain all of the intermediate locale files (i.e. the internal locale database files) for the project you are using the gem in. |
| SUPPORTED_LOCALES | The locales supported by the project you are using the gem in. Needs to be formatted as a comma separated list. Example: "en-US,es-ES,es-MX,ru-RU,fr-CA" |
| SUPPORTED_LOCALES | The locales supported by the project you are using the gem in. Needs to be formatted as a comma separated list. Example: "en-US,es-ES,es-MX,ru-RU,fr-CA" |
| TRANSLATE_PROJECT | The name of the Transifex project the project you are using this gem for uses. |
| TRANSLATE_RESOURCE | The name of the resource inside the Transifex project you are using that you need to update using this gem. |
| TRANSIFEX_BEARER_TOKEN | Your Transifex API key. |
| TRANSLATE_KEY | Google Translate API key (Forced to use generic name for this environment variable, as the google cloud gem we use expects it to be named TRANSLATE_KEY) |
