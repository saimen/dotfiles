if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/*; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

# activate ñ and Ñ
xmodmap -e "keycode 57 = n N n N ntilde Ntilde ntilde"

# if gpg-agent is running, switch it's tty to the X display
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
	gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi

export GPG_AGENT_INFO
export SSH_AUTH_SOCK
export DBUS_SESSION_BUS_PID

compton -bzfCG --shadow-ignore-shaped --backend glx --paint-on-overlay --vsync opengl -D5

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

session=${1:-awesome}

case $session in
	awesome)
		dex -a -e AWESOME;
		exec awesome --no-argb;;
	i3)
		dex -a -e I3;
		exec i3;;
	gnome)
		exec gnome-session;;
	*)
		exec $1;;
esac
