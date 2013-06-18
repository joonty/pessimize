# Pessimize

### What does it do?
Pessimize adds version numbers with the pessimistic constraint operator (`~>`, a.k.a. "spermy" operator) to all gems in your `Gemfile`.

### Why?
You should be using `~> x.x.x` to limit the version numbers of your gems, otherwise `bundle update` could break your application. Read on for a more detailed description, or take a look at the [rubygems explanation][1].

### But why a gem?

When you start building an application that uses bundler, you aren't yet sure which versions of gems will work together, so you probably won't specify the versions. In fact, you normally only do this when the application's fairly stable. However, if you have more than a few gems, it's very tedious to collect the version numbers for each gem and add the pessimistic constraint operator to each line in the `Gemfile`.

Pessimize works out the version of each gem from `Gemfile.lock` then generates a new `Gemfile` with the added version constraints. There's no need to do a `bundle install` afterwards, as nothing's changed - it's just been set in stone.

## Installation

You don't need to add it to your Gemfile - it's best kept as a system-wide gem. All you need to do is install it from the command line:

    $ gem install pessimize

This installs the command line tool `pessimize`.

## Usage

Change to a directory that contains a `Gemfile` and execute:

    $ pessimize

This backs up the existing `Gemfile` and creates a new one with everything neatly organised and versioned.

And that's it!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://docs.rubygems.org/read/chapter/16#page74
