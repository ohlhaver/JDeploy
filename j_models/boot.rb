set :jurnalo, 'jurnalo'
set :root, 'root'
set  :user do 
  Capistrano::CLI.ui.ask "User: "
end
set :use_sudo, false

#role :machines, '174.143.172.95'
set :soft_repo_path, "/home/#{jurnalo}/softRepo"

role :db, '174.143.172.95', :primary => true
role :app,  '174.143.172.95', '174.143.171.52', '174.143.169.37', 'api.jurnalo.com', '174.143.175.163'   # JTier1-To-Api, JMasterInterface, JUserInterface
role :sphinx, '67.23.42.240'       # Sphinx
role :bgserver, '174.143.175.195'  # Background Server Running Clustering
role :bgserver2, '67.23.42.203'     # Background Server Running Email Alerts and Quality Ratings
role :juser, '174.143.169.37', 'api.jurnalo.com'
role :jmaster, '174.143.171.52'
role :jt2m2, '174.143.175.163'
role :jthumb, '174.143.175.129'

set  :application, 'JModels'
set  :deploy_to,   "/home/#{jurnalo}/apps/#{application}"

default_run_options[:pty] = true
set :scm,           :git
set :scm_passphrase, "rosenwel"
set :repository,    "git@github.com:ohlhaver/JModels.git"
set :branch,        "master"
set :keep_releases, 3
set :deploy_via,    :remote_cache


load '../lib/boot.rb'
set :ruby_ee_path,'/opt/ruby-enterprise-edition'
set :rebuild_sphinx_index, :false
set :rake, '/opt/ruby-enterprise-edition/bin/rake'
load '../lib/methods.rb'
load '../lib/build_software_repository.rb'
load '../lib/install.rb'
load '../lib/setup.rb'
load 'script/custom_deploy'

