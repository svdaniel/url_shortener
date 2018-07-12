
yum update -y

yum install -y  gcc gcc-c++ make git patch openssl-devel zlib-devel readline-devel sqlite-devel bzip2-devel

yum install https://centos7.iuscommunity.org/ius-release.rpm -y

yum install -y python36u python36u-pip python36u-devel


# create ssh key
ssh-keygen -t rsa -b 4096 -C "daniel.svoboda@twisto.com" -N "" -f ~/.ssh/id_rsa

git init
git clone https://github.com/svdaniel/url_shortener.git

cd url_shortener/ansible

# add master key to remote host
# cd to root directory of ansible setup (where ansible.cfg is)
ansible-playbook django_nginx_setup/roles/deploy_authorized_key/tasks/main.yml -i django_nginx_setup/hosts -k

# create priviledged user
ansible-playbook django_nginx_setup/site.yml -i django_nginx_setup/hosts
