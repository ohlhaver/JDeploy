namespace :deploy do
 
  task :before_setup do
   set_user(jurnalo)
  end
  
  task :before_update do
   set_user(jurnalo)
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{release_path}/tmp/restart.txt"
    servers = find_servers_for_task(current_task) & roles[:sitemap].servers
    if servers.any?
      sleep 5
      run "curl --silent http://www.jurnalo.com/stylesheets/base_g10.css > /dev/null"
      run "curl --silent http://www.jurnalo.com/stylesheets/base_g10ie.css > /dev/null"
      run "curl --silent http://www.jurnalo.com/stylesheets/base_app.css > /dev/null"
      run "curl --silent http://www.jurnalo.com/stylesheets/jbase.js > /dev/null"
    end
  end
  
  after "deploy:update", 'deploy:sitemap_tasks'
  
  
  task :sitemap_tasks, :roles => :sitemap do
    servers = find_servers_for_task(current_task) & roles[:sitemap].servers
    if servers.any?
      run "ln -s #{deploy_to}/shared/sitemaps #{release_path}/public/sitemaps", :hosts => servers
    end
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
