#!/bin/bash 

# App Environment
sudo mkdir /opt/helloworld  /var/log/hello-world
sudo useradd -r tomcat
sudo mv /tmp/helloworld.jar  /opt/helloworld/
sudo mv /tmp/helloworld.sh /etc/init.d/
sudo mv /tmp/helloworld.service /lib/systemd/system/
sudo chown -R tomcat:tomcat /opt/helloworld /var/log/hello-world
sudo chmod 755 /opt/helloworld/helloworld.jar
sudo chown -R root:root /etc/init.d/helloworld.sh 

#Logs
sudo su root -c "sed -i '/^region/d'  /etc/awslogs/awscli.conf"
sudo su root -c "echo 'region = eu-west-1' >> /etc/awslogs/awscli.conf"
sudo su root -c "cat /tmp/app_awslogs.conf >> /etc/awslogs/awslogs.conf"

#Enable services
sudo systemctl daemon-reload
sudo systemctl enable awslogsd.service
sudo systemctl enable helloworld.service
sudo systemctl start helloworld.service
