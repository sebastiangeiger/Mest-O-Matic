$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
require "bundler/capistrano"

set :application, "Mest-O-Matic"
set :repository, "git@github.com:sebastiangeiger/Mest-O-Matic.git"
set :deploy_to, "/var/www/#{application}"
set :rvm_ruby_string, 'ruby-1.9.2@mestomatic'

set :scm, :git
set :branch, "master"
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
set :use_sudo, false

set :user, "deploy"
#set :password, "secret"
server "192.168.165.135", :app, :web, :db, :primary => true

#passenger
namespace :deploy do
 task :start do ; end
 task :stop do ; end
 task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
 end
end

after "deploy:update_code", "configure:create_css"
namespace :configure do
  task :create_css, :roles => :app do
    run "cd #{current_release}/public/stylesheets && bundle exec sass layout.scss layout.css"
  end
  
  task :transfer_conf_file, :roles => :app do
    upload("config/production.yaml", "#{current_release}/config/production.yaml", :via => :scp)
  end
end
