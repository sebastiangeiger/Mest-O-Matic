source 'http://rubygems.org'

gem 'rails', '3.0.7'

gem 'sqlite3'
gem "paperclip", "~> 2.3" #file attachments

gem 'haml' #using haml instead of erb
gem 'sass'

gem 'ruby-openid'
gem 'rack-openid'
gem 'ruby-openid-apps-discovery'

gem 'zipruby'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  # To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'annotate-models'
  gem 'mongrel', '1.2.0.pre2'         #getting WEBrick::HTTPStatus::RequestURITooLarge in conjunction with openid
  gem "rspec-rails", "~>2.3"
  gem "railroady"
end

group :test do
	gem "rspec-rails", "~>2.3"
	gem "autotest"
	gem "autotest-growl"
	gem "mocha"
	gem 'cover_me', '>= 1.0.0.rc6'
	gem 'capybara', :git => 'git@github.com:/jnicklas/capybara.git'
 	gem "launchy"
end

group :deployment do
  gem "passenger"
  # Deploy with Capistrano
  gem 'capistrano'
end

