if [[ -e /etc/profile.d/linux-toolbox.sh ]]; then
	sudo rm -f /etc/profile.d/linux-toolbox.sh
fi
if [[ -e /etc/profile.d/01-linux-toolbox.sh ]]; then
	sudo rm -f /etc/profile.d/01-linux-toolbox.sh
fi
if [[ -e /etc/profile.d/00-environment.sh ]]; then
	sudo mv /etc/profile.d/00-environment.sh /etc/profile.d/50-environment.sh
fi
