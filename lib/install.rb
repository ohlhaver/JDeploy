namespace :install do

  task :pending do
  end

  task :all do
    install::essential
    install::git
    install::mysql
    install::ruby_enterprise_edition
    install::rubygems
    install::gem_mysql
    install::gem_active_record
  end

  task :essential do
    set_user(root)
    run <<-CMD
      yum -y install gcc gcc-c++ make
    CMD
  end

  task :git do
    set_user(root)
    install::git
    run <<-CMD
      yum -y install gettext-devel expat-devel curl-devel zlib-devel openssl-devel
    CMD
    run <<-CMD
      cd /tmp && rm -rf git* &&
      cp #{soft_repo_path}/git-1.6.4.4.tar.gz . && tar -xvzf git-1.6.4.4.tar.gz &&
      cd git-1.6.4.4 && make && make prefix=/usr install && make clean &&
      rm -rf git*
    CMD
  end

  task :mysql do 
    set_user(root)
    run <<-CMD
      yum -y install mysql-server mysql mysql-devel
    CMD
  end

  task :ruby_enterprise_edition do
    set_user(root)
    set :software, "ruby-enterprise-1.8.6-20090610"

    run <<-CMD
      yum -y install gcc zlib zlib-devel openssl openssl-devel readline readline-devel bison
    CMD

    set :prefix, "/opt/ruby-enterprise-edition"

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
      export PATH=/opt/ruby-enterprise-edition/bin:$PATH &&
      ruby setup.rb &&
      rm -rf #{software}*
    CMD
  end

  task :gem_mysql do 
    set_user(root)
    run <<-CMD
      export PATH=/opt/ruby-enterprise-edition/bin:$PATH &&
      gem install -y mysql
    CMD

  end


  task :gem_active_record do 
    set_user(root)
    run <<-CMD
      export PATH=/opt/ruby-enterprise-edition/bin:$PATH &&
      gem install -y activerecord -v 2.1.0
    CMD
  end
  

end
