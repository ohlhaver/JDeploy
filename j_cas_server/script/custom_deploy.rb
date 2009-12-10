namespace :deploy do
 
  task :before_setup do
   set_user(jurnalo)
  end
  
  task :before_update do
   set_user(jurnalo)
  end
  
  #
  # This tasks assumes we know the location of the JModels app
  #
  task :after_update_code, :roles => :app do
    run "ln -s #{release_path}/config.yml.production #{release_path}/config.yml"
    run "ln -s #{release_path}/ssl/development.cert.pem #{release_path}/ssl/production.cert.pem"
    run "ln -s #{release_path}/ssl/development.cert.key #{release_path}/ssl/production.cert.key"
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{release_path}/tmp/restart.txt"
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
  task :nginx do
   set_user(root)
   run <<-CMD
     cp #{deploy_to}/current/config/nginx.conf #{nginx_path}/conf/nginx.conf
   CMD
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
   install::gems::rails
   install::gems::passenger
   install::nginx_from_passenger
 end
end

namespace :manage do
  namespace :nginx do
   task :start do
     # Please start manually the following code is not working due to some reason
     #set_user(root)
     #run <<-CMD
     #  export PATH=#{ruby_ee_path}/bin:$PATH &&
     #  cd #{nginx_path} && ./sbin/nginx
     #CMD
   end
   task :stop do
     set_user(root)
     run <<-CMD
       killall -u $USER -v nginx
     CMD
   end
  end
end
