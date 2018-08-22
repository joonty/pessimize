module Pessimize
  class VersionMapper
    def call(gems, versions, version_constraint)
      gems.each do |gem|
        if versions.has_key? gem.name
          version = versions[gem.name]
          if !::Gem::Version.new(version).prerelease?
            version_parts = versions[gem.name].split('.')
            version_parts = version_constraint == 'minor' ? version_parts.first(2) : version_parts
            version = version_parts.join('.')
          end
          gem.version = "~> #{version}"
        end
      end
    end
  end
end
