#!/bin/bash

declare current_pa
declare -i is_rtp=0
declare mpd_state
declare mpd_state2

# TODO: Put in a test for if you have a default.pa in user directory
# TODO: Put in a SED type test if you use the PA equalizer
# TODO: Autodetect the number and type of MPC outputs


if [[ "$@" =~ "-h" ]]; then
	echo "This script toggles or turns on/off RTP modules in your pulseaudio."
	echo "If you have other user preferences for PA in $HOME/.config/pulse, "
	echo "you will want to merge them into the examples in this archive."
	echo "Your defaults are not touched."
	echo "usage --help: this msg; --on: turns on rtp; --off: turns off rtp"
	exit
fi

current_pa=$(pacmd list-sinks)

if [[ "$current_pa" =~ "No PulseAudio daemon running" ]]; then
	# For "No daemon running or not system session error"
	# https://bbs.archlinux.org/viewtopic.php?id=155649
	# export PULSE_RUNTIME_PATH="/run/user/1000/pulse/"  
	# Yours may vary.
	# this doesn't work, though.
	#eval $(export PULSE_RUNTIME_PATH="/run/user/1000/pulse/")
	current_pa=$(pacmd list-sinks)
fi


if [[ "$current_pa" =~ "sink(s) available." ]]; then
	is_rtp=$(echo "$current_pa" | grep -c -e rtp -e RTP)
	echo "$is_rtp"
	mpd_state=$(mpc | grep -e "\[" | awk -F "]" '{print $1}' | cut -c 2- )
	if [[ $is_rtp > 0 ]] && [[ "$@" =~ "--off" ]];then
		pulseaudio --kill
		mpd --kill
		cp -f $HOME/.config/pulse/defaultnortp_pa $HOME/.config/pulse/default.pa
		pulseaudio --daemonize --start	
		mpd
		sleep 1
		echo "Waiting to switch outputs"
		# If you want mpc to switch outputs, do it here.
		mpc disable 3  #rtp, which echoes locally
		mpc enable 2  #pulse
	elif [[ $is_rtp = 0 ]] && [[ "$@" =~ "--on" ]];then
		pulseaudio --kill
		mpd --kill
		cp -f $HOME/.config/pulse/defaultrtp_pa $HOME/.config/pulse/default.pa
		pulseaudio --daemonize --start
		mpd
		echo "Waiting to switch outputs"
		sleep 1
		# If you want mpc to switch outputs, do it here.
		mpc disable 2  #pulse
		mpc enable 3  #rtp, which echoes locally
	else
		>&2 echo "Command not specified or RTP module already in requested state."
	fi
	
	# checking to see if MPD is in the same state as we left it
	echo "$mpd_state"
	mpd_state2=$(mpc | grep -e "\[" | awk -F "]" '{print $1}' | cut -c 2- )
	echo "$mpd_state2"
	if [[ "$mpd_state2" != "$mpd_state" ]];then
		# It's actually the same command to start it up again for play and pause
		echo "woo"
		mpc play
	fi
else
	>&2 echo "Pulseaudio does not appear to be in a working state, or won't let me touch it."
fi
