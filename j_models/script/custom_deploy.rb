namespace :deploy do
 
  task :before_setup do
   set_user(jurnalo)
  end
  
  task :before_update do
   set_user(jurnalo)
  end
  
  task :after_update_code, :roles => [:app, :sphinx, :db] do
  end
  
  task :after_update, :roles => :sphinx do
    run "rm -f #{release_path}/config/sphinx.yml"
    run "ln -s #{deploy_to}/shared/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -s #{deploy_to}/shared/sphinx_data #{release_path}/sphinx_data"
  end
  
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
