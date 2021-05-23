
require_relative "lib/db/migrate/version"

Gem::Specification.new do |spec|
	spec.name = "db-migrate"
	spec.version = DB::Migrate::VERSION
	
	spec.summary = "Database migrations."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/db-migrate"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "migrate", "~> 0.3"
	spec.add_dependency "db"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.0"
end
