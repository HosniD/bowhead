#! /bin/bash

#
# install and configure bowhead
#

phpenmod trader
phpenmod mcrypt
service php7.1-fpm start
service mysql start
service redis-server start
adduser www-data root

pushd /etc/nginx/sites-enabled
ln -s ../sites-available/bowhead.conf .
popd

mysqladmin -u root password password
echo "CREATE DATABASE bowhead;" | mysql -u root -ppassword

cd ~
git clone https://github.com/joeldg/bowhead.git
cd bowhead
pip install python-env

echo "-----------------------------------------------------------------"
echo "------ THIS IS GOING TO TAKE A LITTLE WHILE ..... please wait. --"
echo "-----------------------------------------------------------------"
composer update
cp .env.example .env

ln -s /var/www/bowhead/public /var/www/html/bowhead

mkfifo quotes
mysql -u root -ppassword -D bowhead < app/Scripts/DBdump.sql

php artisan bowhead:example_usage

#/usr/bin/crontab /usr/src/crontab.tmp
#/usr/sbin/service cron start

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+----- READ ME:                                                     -----+"
echo "+------------------------------------------------------------------------+"
echo "+----- Bowhead is now set up:                                       -----+"
echo "+----- you need to modify your /root/bowhead/.env                   -----+"
echo "+-----                                                              -----+"
echo "+----- SWAP TO A DIFFERENT TERMINAL TO CONNECT TO THIS INSTANCE     -----+"
echo "+----- USE: 'docker ps' to see instance id (on the left)            -----+"
echo "+----- USE: 'docker exec -it {id} /bin/bash to get terminal access  -----+"
echo "+-----                                                              -----+"
echo "+-----  oanda streaming is going to 'Fatal' exit until              -----+"
echo "+-----  you set your OANDA_TOKEN in .env                            -----+"
echo "+-----                                                              -----+"
echo "+-----  use: 'php artisan bowhead:example_usage' for testing .env   -----+"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# fire up supervisord
/usr/bin/supervisord