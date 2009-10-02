namespace :install do

  task :essential do
    set_user(root)
    run <<-CMD
      yum -y install gcc gcc-c++ make
    CMD
  end

  task :git do
    set_user(root)
    run <<-CMD
      yum -y install gettext-devel expat-devel curl-devel zlib-devel openssl-devel
    CMD
    software = "git-1.6.4.4"
    ext      = ".tar.gz"
    run <<-CMD
      cd /tmp && rm -rf #{software}* &&
      cp #{soft_repo_path}/#{software}#{ext} . && tar -xvzf #{software}#{ext} &&
      cd #{software} && make && make prefix=/usr install && make clean &&
      rm -rf #{software}*
    CMD
  end

  task :mysql do 
    set_user(root)
    run <<-CMD
      yum -y install mysql-server mysql mysql-devel
    CMD
  end

  task :ruby_ee do
    set_user(root)
    set :software, "ruby-enterprise-1.8.6-20090610"

    run <<-CMD
      yum -y install gcc zlib zlib-devel openssl openssl-devel readline readline-devel bison
    CMD

    set :prefix, ruby_ee_path

    run <<-CMD
      cd /tmp && rm -rf #{software}* && rm -rf #{prefix} &&
      cp #{soft_repo_path}/#{software}.tar.gz . && tar -xvzf #{software}.tar.gz &&
      cd #{software} &&
      cd source/vendor/google-perftools-* &&
      ./configure --prefix=#{prefix} --disable-dependency-tracking &&
      make libtcmalloc_minimal.la &&
      mkdir -p #{prefix}/lib/ &&
      rm -f #{prefix}/lib/libtcmalloc_minimal*.so* &&
      cp -Rpf .libs/libtcmalloc_minimal*.so* #{prefix}/lib/ &&
      cd ../../ &&
      ./configure --prefix=#{prefix} &&
      sed -i 's/^LIBS =/LIBS = $(PRELIBS)/g' Makefile &&
      make PRELIBS="-Wl,-rpath,#{prefix}/lib/ -L#{prefix}/lib/ -ltcmalloc_minimal"  &&
      make install &&
      cd /tmp && rm -rf #{software}*
    CMD
    run <<-CMD
      echo 'export PATH=#{prefix}/bin:$PATH' >> /root/.bashrc &&
      echo "echo 'export PATH=#{prefix}/bin:\\$PATH' >> /home/#{jurnalo}/.bashrc;exit" | su #{jurnalo} >/dev/null 2>/dev/null 
    CMD
  end

  task :rubygems do
    set_user(root)
    set :software, "rubygems-1.3.5"
    run <<-CMD
      cd /tmp && rm -rf #{software}* &&
      cp #{soft_repo_path}/#{software}.tgz . && tar -xvzf #{software}.tgz && cd #{software} &&
      export PATH=#{ruby_ee_path}/bin:$PATH &&
      ruby setup.rb &&
      rm -rf #{software}*
    CMD
  end

  task :nginx_from_passenger do
    set_user(root)
    set :software, "nginx"
    run "export PATH=#{ruby_ee_path}/bin:$PATH && passenger-install-nginx-module --auto --prefix=#{nginx_path} --auto-download" do |channel, stream, data|
      puts data
      if data =~ /Here's what you can expect from the installation process\:/
        puts "here is the input"
      end
    end
  end

  namespace :gems do 
    ['mysql','activerecord','eventmachine','eventmachine_httpserver','daemons','passenger'].each do |g|
      task g.to_sym do
        version = ''
        version = '-v 2.1.0'  if g == 'activerecord'
        version = '-v 0.12.8' if g == 'eventmachine'
        version = '-v 0.1.1'  if g == 'eventmachine_httpserver'
        version = '-v 1.0.10' if g == 'daemons'
        version = '-v 2.2.4'  if g == 'passenger'
        version = "-v #{ENV['version']}"  if ENV['version']
        set_user(root)
        run <<-CMD
          export PATH=#{ruby_ee_path}/bin:$PATH &&
          gem install -y #{g} #{version}
        CMD
      end
    end
  end
end
