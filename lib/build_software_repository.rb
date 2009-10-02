namespace :b_s_r do 
  def init
    set_user(jurnalo)
    params = {}
    params[:method] = 'copy'
    params[:remote_repo_ip] = master_repository_ip
    if ENV['method'] == 'copy'
      params[:method] = 'copy'
      params[:remote_repo_ip] = ENV['remote_repo_ip'] || master_repository_ip
    end
    if ENV['method'] == 'download'
      params[:method] = 'download'
    end

    return params
  end
  ['git','ruby_ee','rubygems'].each do |soft|
    task "add_#{soft}".to_sym do 
      if soft == 'git'
        software     = 'git-1.6.4.4'
        ext          = '.tar.gz'
        download_url = "http://kernel.org/pub/software/scm/git/#{software}#{ext}" 
      elsif soft =='ruby_ee'
        software     = 'ruby-enterprise-1.8.6-20090610'
        ext          = '.tar.gz'
        download_url = "http://rubyforge.org/frs/download.php/58677/#{software}#{ext}" 
      elsif soft =='rubygems'
        software = 'rubygems-1.3.5'
        ext      = '.tgz'
        download_url = "http://rubyforge.org/frs/download.php/60718/#{software}#{ext}" 
      end
      
      params   = init
      if params[:method] == 'copy'
        run <<-CMD
          mkdir -p #{soft_repo_path} &&
          cd #{soft_repo_path} &&
          rm -rf #{software}#{ext}
        CMD
        set :remote_repo_password do 
          Capistrano::CLI.password_prompt("passowrd for repository #{jurnalo}@#{params[:remote_repo_ip]}: ")
        end

        run "cd #{soft_repo_path} && scp #{jurnalo}@#{params[:remote_repo_ip]}:#{soft_repo_path}/#{software}#{ext} ." do |channel,stream,data| 
          if data =~ /Are you sure you want to continue connecting \(yes\/no\)\?/
            channel.send_data "yes\n"
          end
          if data =~ /password\:/
            channel.send_data "#{remote_repo_password}\n"
          end
        end
      elsif params[:method] == 'download'
        run <<-CMD
          mkdir -p #{soft_repo_path} &&
          cd #{soft_repo_path} &&
          wget -c http://kernel.org/pub/software/scm/git/#{software}#{ext}
        CMD
      end
    end
  end
  #    wget -c http://rubyforge.org/frs/download.php/58677/ruby-enterprise-1.8.6-20090610.tar.gz
  #    wget -c http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
end
