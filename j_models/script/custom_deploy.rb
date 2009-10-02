namespace :deploy do
 
  task :before_setup do
   set_user(jurnalo)
  end
  task :before_update do
   set_user(jurnalo)
  end
end
namespace :db do
 
  task :migrate do
   set_user(jurnalo)
   set :ruby_path, ruby_ee_path
   run <<-CMD
     export PATH=#{ruby_path}/bin:$PATH &&
     cd #{deploy_to}/current &&
     ruby ./script/migrate ENV=production
   CMD
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
