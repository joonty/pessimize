module Pessimize
  class VersionMapper
    def call(gems, versions, version_constraint)
      gems.each do |gem|
        if versions.has_key? gem.name
          version_parts = versions[gem.name].split('.')
          version = version_constraint == 'minor' ? version_parts.first(2).join('.') : version_parts.join('.')
          gem.version = "~> #{version}"
        end
      end
    end
  end
end
