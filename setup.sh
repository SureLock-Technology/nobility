# prelim
sudo apt update
sudo apt-get install -y python3 python3-pip python3-venv python3-tk apache2 libapache2-mod-wsgi-py3 sqlite3
sudo python3 -m venv ./venv
alias python3="venv/bin/python3"
source venv/bin/activate
sudo venv/bin/python3 -m pip install -r requirements.txt

# .env config
key=$(openssl rand -base64 32)
echo "SECRET_KEY=${key}" > .env
printf "hostname (name of your website, or IP address): "
read hostname
echo "ALLOWED_HOSTS=${hostname},127.0.0.1" >> .env
echo "STATIC_URL='static/'" >> .env
echo "STATIC_ROOT='static/'" >> .env
echo "MEDIA_URL='media/'" >> .env
echo "MEDIA_ROOT='media/'" >> .env

# site setup
sudo python3 manage.py collectstatic
sudo sed "s/changeMe/${USER}/g" default_setup/defaultApache > tmp
sudo cp tmp /etc/apache2/sites-available/royal.conf
sudo a2ensite royal.conf
sudo a2dissite 000-default.conf

# permissions and db
sudo rm db.sqlite3
sudo touch db.sqlite3 && mkdir media
sudo chown www-data:www-data  db.sqlite3
sudo python3 manage.py migrate --run-syncdb
sudo python3 manage.py makemigrations
sudo python3 manage.py migrate
sudo chown -R www-data:www-data ../nobility
sudo chmod -R 775 media
sudo chmod 664 db.sqlite3

# new user
printf "New admin user: "
        read username
sudo python3 manage.py createsuperuser --username=${username} --email=''

export DJANGO_SETTINGS_MODULE=royal.settings

sudo systemctl enable apache2
sudo systemctl restart apache2