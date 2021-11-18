# RakeLocales

Ruby gem compiling all of the rake tasks for locales used in retroelk repository.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rake_locales'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rake_locales

## Usage

Below is a list of commands you can run through the use of the `rake_locales` gem. Make sure you have pulled from the recent version of `master` branch before running `rake locales:update`.

```
rake locales:update
```

Runs all of the steps needed to update the translation files.

```
rake locales:update_databases
```
Generates an initial locale database for a new locale entry

```
rake locales:transifex_export
```

Generates locale files that are ready to be translated by transifex.

```
rake locales:transifex_import
```

Downloads the transifex database and update the public locales.

```
rake locales:verify
```

Verifies whether or not there are translation files that do not match or if there are English files that have not uet been translated. Prompts the user to run `rake locales:update`


