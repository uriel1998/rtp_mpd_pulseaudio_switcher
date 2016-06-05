# rtp_mpd_pulseaudio_switcher
A script in bash to switch MPD outputs to turn on and off RTP multicast across the LAN.

#About

Simple bash script to turn off rtp by swapping pulseaudio pref files in
user config directory. Also toggles MPD.

Because RTP takes up bandwidth across your LAN.

Related: If you're having trouble with RTP and UFW, [see my UFW setup script](https://github.com/uriel1998/ufw-iptables-archer), or try using the following commands:

	sudo iptables -A ufw-before-input -p igmp -d 224.0.0.0/4 -j ACCEPT
	sudo iptables -A ufw-before-output -p igmp -d 224.0.0.0/4 -j ACCEPT

	sudo ufw allow in proto udp from 224.0.0.0/4
	sudo ufw allow in proto udp to 224.0.0.0/4

Related: If you're having problems with UFW clobbering your wifi, you can
filter it at the router level if you're using DD-WRT. Try this code in your
firewall:

	insmod ebtables 
	insmod ebtable_filter 
	iptables -I FORWARD -m pkttype --pkt-type multicast -i br0 -j DROP 
	
(via https://www.dd-wrt.com/phpBB2/viewtopic.php?t=39743&sid=9c70ab89bc1f41f3ca142036fe3c83b4 )


#Prerequisites

Pulseaudio  
MPD  
MPC  

They should all be available in your distro.

#Installation

Copy it. run it as necessary. I call it by a combination of a tasker task and SSH plugin.

If you have user configurations in $HOME/.config/pulse, you will want to
merge them into the included files. **$HOME/.config/pulse/default.pa will be overwritten.**

Remember, the user config can be only overriding values (if you include the default),
which I've done in these snippets.

You'll need to put in the appropriate pulseaudio switches as well.

You will want to edit the switcher script with the appropriate MPD outputs.

Use mpc to determine what outputs you switch to and from 

	mpc outputs
	Output 1 (Icecast Radio) is disabled
	Output 2 (My Pulse Output) is enabled
	Output 3 (MPD RTP) is disabled

#TODO

* Use sed so that it's not clobbering user default.pa if you have additonal stuff in there.
* Detect MPD outputs so you don't have to hardcode them

