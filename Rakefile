require 'rake'

# Primary setup task
task setup: [:hello, :install_node, :install_lunchy, :term, :configure_git, :editor] do
  puts "Setup complete"
end

# Start message and brew update
task :hello do
  puts "Beginning Setup"
  puts %x{ brew update }
end

task :install_node do
  puts %x{ brew install node }
  puts %x{ npm install n -g }
  puts %x{ sudo n latest }
end

# configure the terminal

task term: [:install_zsh, :setup_prezto, :tmux]

task :install_lunchy do
  unless system %{ lunchy }
    puts "Installing Lunchy"
    puts %x{brew install lunchy}
  end
end

task :install_zsh do
  puts "Setting default shell to zsh"
  if ENV["SHELL"].include? 'zsh' then
    puts "Good for you, you're already using zsh"
  else
    puts "executing chsh"
    puts %x{ chsh -s /bin/zsh }
  end
end

task :setup_prezto do
  puts "Installing prezto"
  FileUtils.ln_s File.expand_path('./prezto'), File.expand_path('~/.zprezto'), :force => true
  Dir.glob('./prezto/runcoms/z*').each do |f|
    file_name = f.split('/').last
    puts(file_name)
    puts "Symlink " + f  + " "  + file_name
    FileUtils.ln_s File.expand_path(f), File.expand_path("~/.#{file_name}"), :force => true

  end
  Dir.glob('./prezto-custom/z*').each do |f|
    file_name = f.split('/').last
    puts "Symlink " + f  + " "  + file_name
    FileUtils.ln_s File.expand_path(f), File.expand_path("~/.#{file_name}"), :force => true
  end
  prompt_file = 'prompt_matt_setup'
  puts "Symlink " + prompt_file
  FileUtils.ln_s File.expand_path("./prezto-custom/#{prompt_file}"),
    File.expand_path("~/.zprezto/modules/prompt/functions/#{prompt_file}"),
    :force => true
end

task tmux: [:install_tmux, :configure_tmux]

file 'install_tmux' do
  unless system %{ tmux -V }
    puts "Installing tmux"
    puts %x{ brew install tmux }
  end
end

task :configure_tmux do
  puts "Configuring Tmux"
  source = "#{ENV['PWD']}/tmux/tmux.conf"
  unless File.exists? source
    puts "symlink #{source}"
    system %{ ln -s #{source} ~/.tmux.conf}
  end
end

# install spacemacs
task editor: [:install_neovim, :configure_vim]

task :install_neovim do
  puts "installing neovim"
  puts %x{ brew install neovim }
end

task :configure_vim do
  puts "Configuring vim"
  source = "#{ENV['PWD']}/vim/vimrc"
  puts "symlink #{source}"
  system %{ ln -s #{source} ~/.vimrc }

  source = "#{ENV['PWD']}/vim/init.vim"
  puts "symlink #{source}"
  system %{ ln -s #{source} ~/.config/nvim/init.vim }
end

task :install_emacs do
  puts "installing emacs"
  puts %x{ brew install ispell }
  puts %x{ brew tap railwaycat/emacsmacport }
  puts %x{ brew cask install emacs-mac }
end

task :install_spacemacs do
  puts %x{ git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d }
  FileUtils.ln_s File.expand_path('./spacemacs_layer/romanmt'), File.expand_path('~/.emacs.d/private/romanmt')
  FileUtils.ln_s File.expand_path('./spacemacs_layer/solidity'), File.expand_path('~/.emacs.d/private/solidity')
  FileUtils.ln_s File.expand_path('./spacemacs_layer/snippets'), File.expand_path('~/.emacs.d/private/snippets')
  FileUtils.ln_s File.expand_path('./spacemacs_layer/spacemacs-crystal-layer'), File.expand_path('~/.emacs.d/private/spacemacs-crystal-layer')
end

task :configure_git => ['git'] do
  puts "configuring git"
  FileUtils.ln_s File.expand_path('./git/gitconfig'), File.expand_path('~/.gitconfig')
end
