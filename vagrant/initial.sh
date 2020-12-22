# Put ssh public key into user "ansible" with default password ( It ensure that only root could switch user to "ansible" )
sudo useradd -s /bin/bash -m ansible
cd /home/ansible
sudo mkdir -p .ssh
sudo chmod 777 .ssh
sudo cat /ssh-key/id_rsa.pub >> .ssh/authorized_keys
sudo chmod 700 .ssh
sudo chown ansible:ansible .ssh

# Setting SSH could accept ssh-copy-id on work.
#sudo chmod 777 /etc/ssh/sshd_config
#sudo echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
#sudo sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
#sudo sed -i '/^PubkeyAuthentication/s/no/yes/' /etc/ssh/sshd_config
#sudo chmod 644 /etc/ssh/sshd_config
#sudo /etc/init.d/ssh restart
