set :application,   'compass'
set :repository,    "git@github.com:swhitt/#{application}.git"

task :staging do
  role :web, 'staging.host.name'
  role :app, 'staging.host.name'
  role :db,  'staging.host.name', :primary => true
end

task :production do
  role :web, 'production.host.name'
  role :app, 'production.host.name'
  role :db,  'production.host.name', :primary => true
end


set :keep_releases, 5

set :user, 'deploy'

set :scm,           :git
set :branch,        'master'

set :deploy_to,     "/home/deploy/rails/#{application}"
set :deploy_via,    :remote_cache

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision, 			lambda { source.query_revision(revision) { |cmd| capture(cmd) } }


namespace :deploy do
  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
      cd #{release_path} && ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml
    CMD
  end
  
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
 
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end