# frozen_string_literal: true

require_relative "lib/db/migrate/version"

Gem::Specification.new do |spec|
	spec.name = "db-migrate"
	spec.version = DB::Migrate::VERSION
	
	spec.summary = "Database migrations."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/db-migrate"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/db-migrate/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/socketry/db-migrate.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "db"
	spec.add_dependency "migrate", "~> 0.3"
end
