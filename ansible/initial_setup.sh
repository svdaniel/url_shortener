
useradd twisto --no-create-home
usermod -aG wheel twisto
echo "twisto:shortenme" | chpasswd

yum update -y

yum install -y  gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel sqlite-devel bzip2-devel

yum install https://centos7.iuscommunity.org/ius-release.rpm -y

yum install -y python36u python36u-pip python36u-devel

yum install -y nginx

cd /opt
python3.6 -m venv venv
source venv/bin/activate

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

git init
git clone https://github.com/svdaniel/url_shortener.git

cd url_shortener

pip install -r requirements.txt

deactivate

echo 'yes' | cp ansible/nginx_setup/nginx.conf /etc/nginx/
echo 'yes' | cp ansible/uwsgi_setup/uwsgi.service /etc/systemd/system/

chown -R nginx:nginx /opt/url_shortener/
chown -R nginx:nginx /opt/venv/

python3.6 url_shortener/manage.py collectstatic --noinput

systemctl enable uwsgi
systemctl enable nginx


systemctl daemon-reload

systemctl restart uwsgi
systemctl restart nginx


# May be needed:
	# temp fix for nginx issue >> https://bugs.launchpad.net/ubuntu/+source/nginx/+bug/1581864
	mkdir /etc/systemd/system/nginx.service.d
	printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
	systemctl daemon-reload

