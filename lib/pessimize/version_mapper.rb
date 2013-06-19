module Pessimize
  class VersionMapper
    def call(gems, versions)
      gems.each do |gem|
        if versions.has_key? gem.name
          gem.version = "~> #{versions[gem.name]}"
        end
      end
    end
  end
end
