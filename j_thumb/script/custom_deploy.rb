namespace :deploy do
  task :before_setup do
   set_user(jurnalo)
  end
  task :before_update do
   set_user(jurnalo)
  end
  task :after_update do
    run <<-CMD
     cd #{deploy_to}/current &&
     rm -rf #{storage_dir} &&
     ln -s #{deploy_to}/shared/#{storage_dir} .
    CMD
  end

end

namespace :setup do
 task :pending do
 end
 task :all do
   setup::jurnalo_user
   setup::jurnalo_user_password
   setup::yum_upgrade
 end
 task :storage do
   set_user(jurnalo)
   run <<-CMD
     mkdir -p #{deploy_to}/shared/#{storage_dir} &&
     cd #{deploy_to}/current && rm -rf #{storage_dir} &&
     ln -s #{deploy_to}/shared/#{storage_dir} .
   CMD
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
   install::ruby_ee
   install::rubygems
   install::gems::eventmachine
   install::gems::eventmachine_httpserver
   install::gems::daemons
   install::gems::passenger
   install::nginx_from_passenger
 end
end

namespace :manage do
  namespace :nginx do
   task :start do
     set_user(root)
     run <<-CMD
       cd #{nginx_path} && ./sbin/nginx
     CMD
   end
   task :stop do
     set_user(root)
     run <<-CMD
       killall -u $USER -v nginx
     CMD
   end
  end
  namespace :storage_manager do
   task :start do
     set_user(jurnalo)
     set :ruby_path, ruby_ee_path
     run <<-CMD
       export PATH=#{ruby_path}/bin:$PATH &&
       cd #{deploy_to}/current && ruby ./script/server start
     CMD
   end

   task :stop do
     set_user(jurnalo)
     set :ruby_path, ruby_ee_path
     run <<-CMD
       export PATH=#{ruby_path}/bin:$PATH &&
       cd #{deploy_to}/current && ruby ./script/server stop
     CMD
   end

  end
end
