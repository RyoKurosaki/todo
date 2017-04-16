echo 'export PATH=$HOME/.rbenv/bin:$PATH' >> ~/.bash_profile
echo 'export PATH=$HOME/vendor/bin:$PATH' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 2.3.1 -v
rbenv global 2.3.1

gem install bundler
rbenv rehash
wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

cd /vagrant
bundle install

# rake db:create
# rake db:migrate
