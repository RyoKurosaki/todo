echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
apt-get -y update
apt-get -y upgrade

# Install Ruby
if [[ ! -e /opt/rbenv/bin/rbenv ]]; then
  echo "[Ruby provisioning start]"]

  apt-get install -y build-essential git libssl-dev rbenv libreadline-dev
fi

# Install Postgresql
if [[ ! -e /etc/init.d/postgresql ]]; then
  echo "[postgresql provisioning start]"

  PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
  if [ ! -f "$PG_REPO_APT_SOURCE" ]; then
    # Add PG apt repo:
    echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > "$PG_REPO_APT_SOURCE"
    # Add PGDG repo key:
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
  fi

  apt-get update
  apt-get upgrade

  apt-get install -y postgresql-9.4
  apt-get install -y libpq-dev

  mkdir -p /usr/local/pgsql/data
  chown postgres:postgres /usr/local/pgsql/data
  sudo -u postgres /usr/lib/postgresql/9.4/bin/initdb -D /usr/local/pgsql/data

  sed -i '/local.*/d' /etc/postgresql/9.4/main/pg_hba.conf
  echo "local all all     trust" >> /etc/postgresql/9.4/main/pg_hba.conf
  echo "host  all all all trust" >> /etc/postgresql/9.4/main/pg_hba.conf
  echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
  sed -i 's|UTC|Asia/Tokyo|' /etc/postgresql/9.4/main/postgresql.conf
  update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

  service postgresql restart

  echo "[postgresql provisioning end]"
fi

# Install Redis
if [[ ! -e /etc/init.d/redis ]]; then
  echo "[redis provisioning start]"

  apt-get -y install make

  mkdir /opt/redis
  cd /opt/redis

  # Use latest stable
  wget -q http://download.redis.io/redis-stable.tar.gz
  # Only update newer files
  tar -xz --keep-newer-files -f redis-stable.tar.gz

  cd redis-stable
  make
  make install
  mkdir /var/redis
  chmod -R 777 /var/redis
  useradd redis

  cp -u /vagrant/vagrant/redis/redis.conf /etc/redis.conf
  cp -u /vagrant/vagrant/redis/redis.init.d /etc/init.d/redis

  update-rc.d redis defaults

  chmod a+x /etc/init.d/redis
  /etc/init.d/redis start

  echo "[redis provisioning end]"
fi
