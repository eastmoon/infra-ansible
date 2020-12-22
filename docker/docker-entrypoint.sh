# Put ssh public key into user "ansible" with default password ( It ensure that only root could switch user to "ansible" )
cd /home/ansible
mkdir -p .ssh
chmod 777 .ssh
cat /ssh-key/id_rsa.pub >> .ssh/authorized_keys
chmod 700 .ssh
chown ansible:ansible .ssh

# Setting SSH could accept ssh-copy-id on work.
#chmod 777 /etc/ssh/sshd_config
#echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
#sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
#sed -i '/^PubkeyAuthentication/s/no/yes/' /etc/ssh/sshd_config
#chmod 644 /etc/ssh/sshd_config
/etc/init.d/ssh restart

# Never end
tail -f /dev/null
