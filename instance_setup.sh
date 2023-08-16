#!/bin/bash
sudo useradd XXXX
echo "XXXX" | chpasswd
echo "hadmin ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
echo "Hello"


