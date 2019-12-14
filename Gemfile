source "https://rubygems.org"

gemspec

gem "rdf",      git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"
gem "rdf-spec", git: "git://github.com/ruby-rdf/rdf-spec.git", branch: "develop"

group :debug do
  gem "byebug", platforms: :mri
end

group :test do
  gem 'simplecov',  platforms: :mri
  gem 'coveralls',  '~> 0.8', platforms: :mri
end
