# add twisto user
adduser twisto
passwd twisto
usermod -aG wheel twisto

# create nginx user??


# update system (also solves ca issues with curl/pip that may be appearing)
yum update -y

yum install -y  gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel sqlite-devel bzip2-devel nginx

yum install https://centos7.iuscommunity.org/ius-release.rpm -y

yum install -y python36u python36u-pip python36u-devel

        # pyenv installation && setup
            # git clone git://github.com/yyuu/pyenv.git ~/.pyenv
            # export PATH="$HOME/.pyenv/bin:$PATH"
            # eval "$(pyenv init -)"

            # echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> .bashrc
            # echo 'eval "$(pyenv init -)"' >> .bashrc

            # install python3.6.4
            # pyenv install 3.6.4


cd /opt
python3.6 -m venv venv

git init

# download project from git repo
git clone https://github.com/svdaniel/django-url-shorterer.git

# activate virtualenv
source venv/bin/activate

cd django-url-shorterer/

pip3.6 install --upgrade pip
pip3.6 install -r requirements.txt


# setup firewall if needed
    #iptables -I INPUT 1 -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT

                    #firewall-cmd --add-port=8000/tcp --permanent
                    #systemctl restart firewalld

# for testing put domain into hosts file
    # echo "127.0.0.1   test.twst.cz" >> /etc/hosts

cd django-url-shorterer/frontend

python3.6 manage.py makemigrations
python3.6 manage.py migrate
python3.6 manage.py collectstatic

# for testing this may be running under root, in prod it will run under non-root user
    # python3.6 manage.py runserver test.twst.cz:8000

# testing working gunicorn
    # gunicorn --bind 0.0.0.0:8000 frontend.wsgi:application


# Setup gunicorn daemon
mkdir -p /etc/systemd/system/
mkdir /run/gunicorn

echo -e """\
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
PIDFile=/run/gunicorn.pid
User=root

WorkingDirectory=/opt/django-url-shorterer/django-url-shorterer/frontend
ExecStart=/opt/venv/bin/gunicorn --workers 3 --pid /run/gunicorn/pid --bind 0.0.0.0:8080 frontend.wsgi:application
PrivateTmp=true
# Group=nginx
# ExecStart=/opt/venv/bin/gunicorn --workers 3 --pid /run/gunicorn.pid --bind unix:/opt/django-url-shorterer/django-url-shorterer/frontend/socket frontend.wsgi:application

[Install]
WantedBy=multi-user.target

""" > /etc/systemd/system/gunicorn.service

systemctl enable gunicorn

# Create log directory
mkdir -p /var/log/django-shortener

# Setup Nginx
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

vi /etc/nginx/sites-available/test_twst_cz.conf







# nginx conf


upstream url_shortener {
  # fail_timeout=0 means we always retry an upstream even if it failed
  # to return a good HTTP response (in case the Unicorn master nukes a
  # single worker for timing out).

  server unix:/opt/django-url-shorterer/django-url-shorterer/frontend/socket fail_timeout=0;
}

server {

    listen   80;
    server_name test.twst.cz;

    client_max_body_size 4M;

    access_log /var/log/django-shortener/nginx-access.log;
    error_log /var/log/django-shortener/nginx-error.log;

    location /static/ {
        alias   /opt/django-url-shorterer/django-url-shorterer/static/;
    }

    location / {
            # an HTTP header important enough to have its own Wikipedia entry:
            #   http://en.wikipedia.org/wiki/X-Forwarded-For
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # enable this if and only if you use HTTPS, this helps Rack
            # set the proper protocol for doing redirects:
            # proxy_set_header X-Forwarded-Proto https;

            # pass the Host: header from the client right along so redirects
            # can be set properly within the Rack application
        proxy_set_header Host $http_host;

            # we don't want nginx trying to do something clever with
            # redirects, we set the Host: header above already.
        proxy_redirect off;

            # set "proxy_buffering off" *only* for Rainbows! when doing
            # Comet/long-poll stuff.  It's also safe to set if you're
            # using only serving fast clients with Unicorn + nginx.
            # Otherwise you _want_ nginx to buffer responses to slow
            # clients, really.
            # proxy_buffering off;

            # Try to serve static files from nginx, no point in making an
            # *application* server like Unicorn/Rainbows! serve static files.
        if (!-f $request_filename) {
            proxy_pass http://url_shortener;
            break;
        }
    }

    # Error pages
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /opt/django-url-shorterer/django-url-shorterer/static/;
    }
}


ln -s /etc/nginx/sites-available/test_twst_cz.conf /etc/nginx/sites-enabled/test_twst_cz.conf

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https

firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --reload
systemctl enable nginx



# temp fix for nginx issue >> https://bugs.launchpad.net/ubuntu/+source/nginx/+bug/1581864
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
systemctl daemon-reload



# chown nginx:nginx -R /opt/django-url-shorterer
