namespace :deploy do
  task :before_setup do
   set_user(jurnalo)
  end
  task :before_update do
   set_user(jurnalo)
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
