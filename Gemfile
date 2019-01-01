source "https://rubygems.org"

gemspec

gem "rdf",      git: "git://github.com/ruby-rdf/rdf.git", branch: "develop"
gem "rdf-spec", git: "git://github.com/ruby-rdf/rdf-spec.git", branch: "develop"

group :debug do
  gem "byebug", platforms: :mri
end

group :test do
  gem 'simplecov',  require: false, platform: :mri
  gem 'coveralls',  require: false, platform: :mri
end
