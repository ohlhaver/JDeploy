set :jurnalo, 'jurnalo'
set :root, 'root'
set  :user do 
  Capistrano::CLI.ui.ask "User: "
end
set :use_sudo, false

#role :machines, '174.143.172.95'
set :soft_repo_path, "/home/#{jurnalo}/softRepo"

role :db, '174.143.172.95', :primary => true
role :app,  '174.143.172.95'   # JTier1-To-Api 
role :sphinx, '67.23.42.240'   # Sphinx

set  :application, 'JModels'
set  :deploy_to,   "/home/#{jurnalo}/apps/#{application}"

default_run_options[:pty] = true
set :scm,           :git
set :scm_paraphase, "rosenwel"
set :repository,    "git@github.com:ohlhaver/JModels.git"
set :branch,        "master"
set :keep_releases, 3
set :deploy_via,    :remote_cache


load '../lib/boot.rb'
set :ruby_ee_path,'/opt/ruby-enterprise-edition'
load '../lib/methods.rb'
load '../lib/build_software_repository.rb'
load '../lib/install.rb'
load '../lib/setup.rb'
load 'script/custom_deploy'

