source "https://rubygems.org"

gemspec

gem "rdf",      git: "https://github.com/ruby-rdf/rdf.git", branch: "develop"
gem "rdf-spec", git: "https://github.com/ruby-rdf/rdf-spec.git", branch: "develop"

group :debug do
  gem "byebug", platforms: :mri
end

group :test do
  gem 'simplecov', '~> 0.22',  platforms: :mri
  gem 'simplecov-lcov', '~> 0.8',  platforms: :mri
end
