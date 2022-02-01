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


