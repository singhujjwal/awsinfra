#sudo su -
#unlink /etc/nginx/sites-enabled/default
vim /etc/nginx/conf.d/jenkins.conf


curl -O https://dl.eff.org/certbot-auto
chmod +x certbot-auto 
sudo mv certbot-auto /usr/local/bin/certbot-auto
certbot-auto certonly --standalone -d jenkins.singhjee.in


sudo yum install -y certbot
sudo yum install -y certbot-nginx
# create an A record before
sudo certbot --nginx -d jenkins.singhjee.in -d www.jenkins.singhjee.in
#later block the port 80
