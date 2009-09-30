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
   set :ruby_path, "/opt/ruby-enterprise-edition"
   run <<-CMD
     export PATH=#{ruby_path}/bin:$PATH &&
     cd #{deploy_to}/current &&
     ruby ./script/migrate ENV=production
   CMD
  end
end
