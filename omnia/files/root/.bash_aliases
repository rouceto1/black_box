alias cdd="cd .."
alias cddd="cd ../.."
alias cdddd="cd ../../.."
alias cddddd="cd ../../../.."
alias cdddddd="cd ../../../../.."

alias space="du -sh"

function mkdircd {
	mkdir -p "$1"
	cd "$1"
}

function git-push-user {
	origin=$(git remote get-url origin)
	if echo "${origin}" | grep -q 'git@.*:'; then 
		origin=$(echo "${origin}" | sed 's#:#/#' | sed 's#git@#https://#'); 
	fi

	echo "Pushing to ${origin}"

	git push "$@" ${origin}
}

function vimexec {
	touch "$1"
	chmod +x "$1"
	vim "$1"
}

function pings()
{
  host="$1"
  text="$host"
  if [[ $# -gt 1 ]]; then
    text="$2"
  fi
  ping "$host" | sed -u "s/^.*seq=\([0-9]\+\) .* time=/$(hostname) => $text seq=\\1 time=/"
}

