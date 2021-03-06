set :jurnalo, 'jurnalo'
set :root, 'root'
set  :user do 
  Capistrano::CLI.ui.ask "User: "
end
set :use_sudo, false

role :machines, '174.143.172.94'
set :soft_repo_path, "/home/#{jurnalo}/softRepo"

role :app,         '174.143.172.94'
set  :application, 'JThumb'
set  :deploy_to,   "/home/#{jurnalo}/apps/#{application}"

default_run_options[:pty] = true
set :scm,           :git
set :scm_passphrase, "rosenwel"
set :repository,    "git@github.com:ohlhaver/JThumb.git"
set :branch,        "master"
set :keep_releases, 3
set :deploy_via,    :remote_cache
set :storage_dir, 'storage'

load '../lib/boot.rb'
load '../lib/methods.rb'
load '../lib/build_software_repository.rb'
load '../lib/setup.rb'
load '../lib/install.rb'
load 'script/custom_deploy.rb'
