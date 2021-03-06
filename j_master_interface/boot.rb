set :jurnalo, 'jurnalo'
set :root, 'root'
set  :user do 
  Capistrano::CLI.ui.ask "User: "
end
set :use_sudo, false

role :machines, '174.143.171.52'
set :soft_repo_path, "/home/#{jurnalo}/softRepo"

role :app,         '174.143.171.52'
set  :application, 'JMasterInterface'
set  :deploy_to,   "/home/#{jurnalo}/apps/#{application}"

default_run_options[:pty] = true
set :scm,           :git
set :scm_passphrase, "rosenwel"
set :repository,    "git@github.com:ohlhaver/JMasterInterface.git"
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