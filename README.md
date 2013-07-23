# Pessimize

[![Build Status](https://travis-ci.org/joonty/pessimize.png?branch=master)](https://travis-ci.org/joonty/pessimize)

### Who is this for?
Anyone who works with a Gemfile, i.e. a project that uses [bundler][1].

### What does it do?
Pessimize adds version numbers with the pessimistic constraint operator (`~>`, a.k.a. "spermy" operator) to all gems in your `Gemfile`.

### Why?
You should be using `~> x.x.x` to limit the version numbers of your gems, otherwise `bundle update` could potentially break your application. Read the section on "why bundle update can be dangerous" for a more detailed description, or take a look at the [rubygems explanation][2].

### But why a gem?

*I.e. why not just do it by hand?*

When you start building an application that uses bundler, you aren't yet sure which versions of gems will work together, so you probably won't specify the precise versions. You would normally only do this when the application and it's dependencies are in a fairly stable state. However, if you have more than a few gems, it's very tedious to collect the version numbers for each gem and add the pessimistic constraint operator to each line in the `Gemfile`.

Pessimize works out the version of each gem from `Gemfile.lock` then generates a new `Gemfile` with the added version constraints. But don't worry: it backs up the existing Gemfile before running, so you can get the original back if it goes wrong. (If it does go wrong, please submit an issue.)

## Installation

You don't need to add it to your Gemfile - it's best kept as a system-wide gem. All you need to do is install it from the command line:

    $ gem install pessimize

This installs the command line tool `pessimize`.

## Usage

Change to a directory that contains a `Gemfile` and execute:

    $ pessimize

This backs up the existing `Gemfile` and creates a new one with everything neatly organised and versioned.

And that's it!

## Known issues

Pessimize evaluates the Gemfile as executable ruby code. That means that anything method-like will be retained in the output (e.g. `gem "nokogiri"`, or `source "https://rubygems.org"`), but anything else such as conditional statements will not.

There are plans to fix this: [see this issue][3] for tracking the progress.

## Why `bundle update` can be dangerous

If you add gems to your Gemfile without specifying a version, bundler will attempt to get the latest stable version for that gem. When you first run `bundle install`, bundler will get and install the latest versions, then create a `Gemfile.lock` which specifies the versions used.

This is fine until someone runs `bundle update`. In this case, bundler will try to update each gem to the maximum possible version. If no constraints have been applied, that means that **major** versions can potentially be incremented. Gems have interdependencies with other gems, and if those gems haven't specified the version constraints then breakages could occur.

The pessimistic constraint operator will only allow the final number of the version string to increase. You can use this to only allow patch level upgrades, or minor (if you're feeling dangerous). This means that when you run `bundle update`, there's a limit on how far gems will update.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: http://gembundler.com
[2]: http://docs.rubygems.org/read/chapter/16#page74
[3]: https://github.com/joonty/pessimize/issues/5
