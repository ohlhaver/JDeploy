load 'deploy'
namespace :setup do
  task :pending do
  end

  task :init do
    set_user(root)
    setup::jurnalo_user
    setup::jurnalo_user_password
  end
  task :mysql_init do
    #######################
    # Please do it manually
    #######################
    #
    #set_user(root)
    #run <<-CMD
    #  mysql_install_db --user=mysql
    #CMD


    #set :mysql_root_password do
    #  Capistrano::CLI.password_prompt "Mysql root password: "
    #end
    #set :confirmed_mysql_root_password do
    #  Capistrano::CLI.password_prompt "Confirm mysql root password: "
    #end

    #if mysql_root_password == confirmed_mysql_root_password
    #  run <<-CMD
    #    nohup mysqld_safe >/dev/null &
    #  CMD
    #  run <<-CMD
    #    mysqladmin -uroot password #{mysql_root_password}
    #  CMD
    #  run <<-CMD
    #    mysqladmin -uroot shutdown -p#{mysql_root_password}
    #  CMD
    #  puts "configuration completed successfully"
    #else
    #  puts "Passwords do not match. please run cap setup:mysql_init again."
    #end
  end
  task :soft_repo do
  set_user(jurnalo)
  run <<-CMD
    mkdir -p #{soft_repo_path}
  CMD

  run <<-CMD
    cd soft_repo_path &&
    wget http://kernel.org/pub/software/scm/git/git-1.6.4.4.tar.gz &&
    wget http://rubyforge.org/frs/download.php/58677/ruby-enterprise-1.8.6-20090610.tar.gz &&
    http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
  CMD
  end
  task :upgrade do 
    run <<-CMD
      yum -y upgrade
    CMD
  end
  task :jurnalo_user do 
    set_user(root)
    set :new_user_name, jurnalo
    run <<-CMD
      groupadd #{new_user_name} &&
      useradd -g #{new_user_name} #{new_user_name}
    CMD
    puts "jurnalo user has been successfully created."
  end

  task :jurnalo_user_password do 
    set_user(root)
    set :new_user_name, jurnalo
    set :new_user_password do 
      Capistrano::CLI.password_prompt("passowrd for #{new_user_name}: ")
    end
    set :new_user_confirmed_password do 
      Capistrano::CLI.password_prompt("confirm passowrd for #{new_user_name}: ")
    end

    if new_user_password == new_user_confirmed_password
      run "passwd #{new_user_name}" do |channel, stream, data|
         if data =~ /password: /
           channel.send_data "#{new_user_password}\n"
         end
      end
      puts "password has been successfully setup."
    else
      puts "passwords do not mactch. please run setup:jurnalo_user_password task again."
    end
  end
  task :db do
    set_user(root)
    set :mysql_root_password do 
      Capistrano::CLI.password_prompt("Root passowrd for mysql: ")
    end
    set :production_db_name do 
      Capistrano::CLI.ui.ask("name of production db: ")
    end
    set :production_db_username do 
      Capistrano::CLI.ui.ask("name of production db user: ")
    end

    set :production_db_password do 
      Capistrano::CLI.ui.ask("password for production db user #{production_db_username}@localhost : ")
    end

    run <<-CMD
      echo 'create database #{production_db_name};' | mysql -uroot -p#{mysql_root_password}
    CMD
    run <<-CMD
      echo "GRANT ALL PRIVILEGES ON #{production_db_name}.* TO '#{production_db_username}'@'localhost' IDENTIFIED BY '#{production_db_password}'; FLUSH PRIVILEGES;" | mysql -uroot -p#{mysql_root_password}
    CMD
  end
end
