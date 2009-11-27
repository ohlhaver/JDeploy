namespace :deploy do
  
  task :rebuild_index do
    set :rebuild_sphinx_index, :true
    deploy
  end
  
  task :rebuild_index_with_migrations do
    set :rebuild_sphinx_index, :true
    deploy::migrations
  end
 
  task :before_setup do
   set_user(jurnalo)
  end
  
  task :before_update do
   set_user(jurnalo)
  end
  
  # task :after_update_code, :roles => [:app, :db] do
  #   run "cd #{release_path};#{ruby_ee_path}/bin/rake thinking_sphinx:configure RAILS_ENV=production;cd -"
  # end
  
  task :app_tasks, :roles => :app do
    servers = find_servers_for_task(current_task) & roles[:app].servers
    run "cd #{release_path};#{ruby_ee_path}/bin/rake thinking_sphinx:configure RAILS_ENV=production;cd -", :hosts => servers if servers.any?
  end
  
  task :db_tasks, :roles => :db do
    servers = find_servers_for_task(current_task) & roles[:db].servers
    run "cd #{release_path};#{ruby_ee_path}/bin/rake thinking_sphinx:configure RAILS_ENV=production;cd -", :hosts => servers if servers.any?
  end
  
  task :sphinx_tasks, :roles => :sphinx do
    servers = find_servers_for_task(current_task) & roles[:sphinx].servers
    if servers.any?
      run "rm -f #{release_path}/config/sphinx.yml", :hosts => servers
      run "ln -s #{deploy_to}/shared/sphinx.yml #{release_path}/config/sphinx.yml", :hosts => servers
      run "ln -s #{deploy_to}/shared/sphinx_data #{release_path}/sphinx_data", :hosts => servers
      run "cd #{release_path};#{ruby_ee_path}/bin/rake thinking_sphinx:configure RAILS_ENV=production;cd -", :hosts => servers
      unless "#{rebuild_sphinx_index}" == "false"
        run "cd #{release_path}; #{ruby_ee_path}/bin/rake thinking_sphinx:delayed_delta:stop RAILS_ENV=production; cd -", :hosts => servers
        run "cd #{release_path}; #{ruby_ee_path}/bin/rake thinking_sphinx:build RAILS_ENV=production; cd -", :hosts => servers
        run "cd #{release_path}; #{ruby_ee_path}/bin/rake thinking_sphinx:delayed_delta:start RAILS_ENV=production; cd -", :hosts => servers
      else
        run "cd #{release_path}; #{ruby_ee_path}/bin/rake  thinking_sphinx:delayed_delta:restart RAILS_ENV=production; cd -", :hosts => servers
      end
    end
  end
  
  task :bgserver_tasks, :roles => :bgserver do
    servers = find_servers_for_task(current_task) & roles[:bgserver].servers
    if servers.any?
      run "cd #{release_path};#{ruby_ee_path}/bin/rake thinking_sphinx:configure RAILS_ENV=production;cd -", :hosts => servers
      run "cd #{release_path};#{ruby_ee_path}/bin/rake clustering:restart RAILS_ENV=production; cd -", :hosts => servers
    end
  end
  
  after "deploy:update", 'deploy:app_tasks'
  after "deploy:update", 'deploy:db_tasks'
  after "deploy:update", 'deploy:sphinx_tasks'
  after "deploy:update", 'deploy:bgserver_tasks'
  
  desc "Restart Application"
  task :restart, :roles => :app do
  end
    
end

namespace :setup do
 task :pending do
   #setup::mysql_init
   #setup::db
 end
 task :all do
   setup::jurnalo_user
   setup::jurnalo_user_password
   setup::yum_upgrade
 end
 
end

namespace :b_s_r do
 task :pending do
 end
 task :all do
   b_s_r::add_git
   b_s_r::add_ruby_ee
   b_s_r::add_rubygems
 end
end

namespace :install do
 task :pending do
 end
 task :all do
   install::essential
   install::git
   install::mysql
   install::ruby_ee
   install::rubygems
   install::gems::mysql
   install::gems::activerecord
 end
end
