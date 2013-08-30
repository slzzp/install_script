
setenv  LC_CTYPE        zh_TW.UTF-8
setenv  LC_ALL          zh_TW.UTF-8

# setenv TZ 'Asia/Taipei'

# for screen window
if ( $?WINDOW ) then
  if ( $WINDOW == '0' ) then
    echo "blah"
    exit
  endif

  if ( $WINDOW > '0' ) then
    env LC_ALL='' /usr/bin/cal
    /bin/date
  endif
endif
