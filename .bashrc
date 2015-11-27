#! /usr/bin/env bash
# ~/.bashrc
#


## better parse these from desktop files somehow
export EDITOR=vim
export BROWSER=/usr/bin/firefox
export PDFVIEWER=mupdf

export MC_SKIN=$HOME/.config/mc/sol.ini

# Variables for arduino makefiles
export ARDUINO_DIR=/usr/share/arduino
export ARDMK_DIR=/usr/share/arduino
export AVR_TOOLS_DIR=/usr/bin

alias g="gvim --remote-silent"

shrink_pictures() {
	if [[ -z "$1" || ! -d "$1" ]]
	then
		printf "need a target folder as an argument\n"
		return
	fi

	local TARGET_FOLDER="$1"
	if [[ ! -d "$TARGET_FOLDER/small" ]]
	then
		mkdir "$TARGET_FOLDER/small"
	fi

	for i in  "$TARGET_FOLDER"/*.{jpg,Jpg,JPG}
	do
		if [[ -e "$i" && ! -d "$i" && "${i##*.}" =~ (jpg|Jpg|JPG)$ ]]
		then
			local NEW_NAME
                        NEW_NAME=$(basename -s ".${i##*.}" "${i}"_small."${i##*.}")
			convert "$TARGET_FOLDER/$i" -resize 1280x1024 "$TARGET_FOLDER/small/$NEW_NAME"
		fi
	done
	unset i
}

extract_audio() {
	if [[ -z "$1" || ! -d "$1" ]]
	then
		printf "need a target folder as argument\n"
		return
	fi

	local TARGET_FOLDER="$1"
	if [[ ! -d "$TARGET_FOLDER/audio" ]]
	then
		mkdir "$TARGET_FOLDER/audio"
	fi

	for i in  "$TARGET_FOLDER"/*.{mov,Mov,MOV}
	do
		if [[ ! -d "$i" && "${i##*.}" =~ (mov|Mov|MOV)$ ]]
		then
			local OUTPUT_BASE_NAME
			local OUTPUT_NAME
			OUTPUT_BASE_NAME=$(basename -s ".${i##.}" "$i")
			OUTPUT_NAME="$OUTPUT_BASE_NAME".mp3
			mpv --no-video -ao=pcm:file="$TARGET_FOLDER/$OUTPUT_BASE_NAME".wav "$TARGET_FOLDER/$i"
			lame -V 1 "$TARGET_FOLDER/$OUTPUT_BASE_NAME".wav "$TARGET_FOLDER/audio/$OUTPUT_NAME"
			rm "$TARGET_FOLDER/$OUTPUT_BASE_NAME".wav
		fi
	done
	unset i
}

start_vm() {
	local MACHINE_TYPE=""
	local STANDARD_ARGS="--enable-kvm -machine mem-merge=on -device virtio-net,netdev=mynet0 -netdev user,id=mynet0"
	local SPECIFIC_ARGS=""
	case "$1" in
		"xp")
			MACHINE_TYPE=i386
			SPECIFIC_ARGS="-m 768M -drive file=/home/saimen/Development/winxp.qcow2,index=0,media=disk,if=virtio"
				;;
		"win7")
			MACHINE_TYPE=x86_64
			SPECIFIC_ARGS="-m 786M -drive file=/home/saimen/Development/win7.qcow2,index=0,media=disk,if=virtio"
				;;
		"team20")
			MACHINE_TYPE=i386
			SPECIFIC_ARGS="-m 768M -drive file=/home/saimen/VirtualBox VMs/SamuraiWTF/SamuraiWTF-disk1.vmdk"
				;;
		*)
			printf "No machine %s known to me\n" "$1"
			return
				;;
	esac
	local ARGS=(${STANDARD_ARGS} ${SPECIFIC_ARGS})
	qemu-system-$MACHINE_TYPE "${ARGS[@]}" &
}

restart_gpg_agent() {
	gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
}



# start GPG-Agent
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
	export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
fi

GPG_TTY=$(tty)
export GPG_TTY

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

man() {
	env LESS_TERMCAP_mb="$(printf "\e[01;31m")" \
		LESS_TERMCAP_md="$(printf "\e[01;38;5;74m")" \
		LESS_TERMCAP_me="$(printf "\e[0m")" \
		LESS_TERMCAP_se="$(printf "\e[0m")" \
		LESS_TERMCAP_so="$(printf "\e[38;5;246m")" \
		LESS_TERMCAP_ue="$(printf "\e[0m")" \
		LESS_TERMCAP_us="$(printf "\e[04;38;5;146m")" \
	man "$@"
}

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

WEECHAT_PASSPHRASE=$(pass show IRC/freenode.net)
export WEECHAT_PASSPHRASE

# add toolchains to path
if [ -d ./x-tools ]; then
	for f in $(readlink -f ./x-tools)/*
	do
		if [ -d "$f"/bin ]; then
			PATH="$f"/bin:$PATH
		fi
	done
	unset f
fi

# Fix skype sound
export PULSE_LATENCY_MSEC=90
export PATH=$PATH:~/.cabal/bin:~/.gem/ruby/2.1.0/bin

LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
