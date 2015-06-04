
# generate aliases for host list
setenv HOSTLISTFILE hostlist-`/bin/date "+%Y%m%d" --date='last day'`.alias
if ( -f "$HOSTLISTFILE" ) then
  /bin/rm "$HOSTLISTFILE"
endif

setenv HOSTLISTFILE hostlist-`/bin/date "+%Y%m%d"`.alias

if ( ! -f "$HOSTLISTFILE" ) then
  /bin/touch "$HOSTLISTFILE"

  /usr/bin/ypcat hosts |/bin/grep videopass | /bin/grep -v -- '-ip-10-' | \
    /bin/grep jump | \
    /usr/bin/awk '{printf("alias %s \"ssh -2 -C -v %s \"\n",$2,$1);}' >> "$HOSTLISTFILE"

  /usr/bin/ypcat hosts |/bin/grep videopass | /bin/grep -v -- '-ip-10-' | \
    /bin/grep -v jump | \
    /usr/bin/awk '{printf("alias %s \"ssh -2 -C -v ubuntu@%s \"\n",$2,$1);}' >> "$HOSTLISTFILE"
endif

source "$HOSTLISTFILE"

