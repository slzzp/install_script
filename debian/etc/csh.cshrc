# /etc/csh.cshrc: system-wide .cshrc file for csh(1) and tcsh(1)

if ($?tcsh && $?prompt) then

	bindkey "\e[1~" beginning-of-line # Home
	bindkey "\e[7~" beginning-of-line # Home rxvt
	bindkey "\e[2~" overwrite-mode    # Ins
	bindkey "\e[3~" delete-char       # Delete
	bindkey "\e[4~" end-of-line       # End
	bindkey "\e[8~" end-of-line       # End rxvt

	set autoexpand
	set autolist
	set prompt = "%U%m%u:%B%~%b%# "
endif

umask   022

# Environment Settings
set     path            = ( /usr/local/bin /usr/local/sbin /sbin /usr/sbin /bin /usr/bin )

set     recexact
set     autolist
set     matchbeep       = ambiguous
set     autoexpand
set     autocorrect
set     noclobber
set     notify
set     correct         = all
set     symlinks        = ignore
set     listlinks
set     listjobs
set     rmstar
set     showdots
set     mail            = (/var/mail/$USER)

unset   autologout
set     autologout=0

# set     prompt          = "%B%m [%/] -%n- " 
set     prompt2         = "(%t %m)%~ #%% "
set     prompt3         = "%SDo you mean [%R] (y/n/e) ? "

if ( ! $?WINDOW ) then
    set prompt          = "%{[32m%}%n%{[0m%}@%{[36m%}%m%{[0m%} [%{[32m%}%~%{[0m%}] (%{[36m%}%T%{[0m%}) "
else
    set prompt          = "%{[32m%}%n%{[0m%}@%{[36m%}%m%{[0m%} [%{[32m%}%~%{[0m%}] [%{[36m%}%T%{[0m%}/%{[36m%}W$WINDOW%{[0m%}] "
endif


setenv  LESS            "-srh0Pm-LESS-"
setenv  LESSCHARDEF     "8bcccbcc18b95.."
setenv  PAGER           "less -dEm"
setenv  LC_CTYPE        "en_US.UTF-8"
setenv  LANG            C

# setenv  TERM            vt100

setenv  EDITOR          joe
setenv  PAGER           more
setenv  BLOCKSIZE       K

setenv  TZ              'Asia/Taipei'

alias   md5             '/usr/bin/md5sum '
alias   n               '/usr/bin/nslookup '
alias   joe             '/usr/bin/joe -asis '
alias   s               '/usr/bin/screen -U '
alias   wget            '/usr/bin/wget --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-TW; rv:1.9.2.24) Gecko/20111103 Firefox/3.6.24 (.NET CLR 3.5.30729)" '
