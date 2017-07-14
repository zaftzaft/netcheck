# dhcping: yaourt -S dhcping
# netcheck --dns google.com@8.8.8.8 --ping 8.8.8.8 --dhcp 192.168.0.1

PING_TIMEOUT=3
PING_RETRY=1
HTTP_TIMEOUT=5
DHCP_TIMEOUT=3
DNS_TIMEOUT=3

for OPT in "$@"
do
  case "$OPT" in
    --dns)
      d=`echo $2 | sed -e "s/@/ /"`
      addr=`echo $d | cut -f1 -d " "`
      server=`echo $d | cut -f2 -d " "`

      res=`dig $addr A +timeout=$DNS_TIMEOUT @$server`
      if [ $? -eq 0 ];then
        echo netcheck_dns\{addr=\"$addr\",status=\"result\"\,nameserver=\"$server\"} 1
      else
        echo netcheck_dns\{addr=\"$addr\",status=\"result\"\,nameserver=\"$server\"} 0
      fi

      shift 2
    ;;

    --ping)
      addr=$2
      res=`ping -c $PING_RETRY $addr -w $PING_TIMEOUT`

      if [ $? -eq 0 ]; then
        rtt=`echo $res | grep "time=[0-9]*.[0-9]*" -o | sed -e "s/time=//"`
        rtt=`echo $rtt | sed -e "s/^.* //"`
        echo netcheck_ping\{addr=\"$addr\",status=\"result\"\} 1
        echo netcheck_ping\{addr=\"$addr\",status=\"rtt\"\} $rtt
      else
        echo netcheck_ping\{addr=\"$addr\",status=\"result\"\} 0
      fi

      shift 2
    ;;

    --dhcp)
      addr=$2
      res=`dhcping -t $DHCP_TIMEOUT -s $addr -q`
      code=$?

      if [ $code -eq 0 ]; then
        echo netcheck_dhcp\{addr=\"$addr\",status=\"result\"\} 1
        echo netcheck_dhcp\{addr=\"$addr\",status=\"exit_code\"\} $code
      else
        echo netcheck_dhcp\{addr=\"$addr\",status=\"result\"\} 0
        echo netcheck_dhcp\{addr=\"$addr\",status=\"exit_code\"\} $code
      fi

      shift 2
    ;;

    --http)
      addr=$2
      res=`curl --silent $addr --connect-timeout $HTTP_TIMEOUT`
      code=$?
      if [ $code -eq 0 ]; then
        echo netcheck_http\{addr=\"$addr\",status=\"result\"\} 1
        echo netcheck_http\{addr=\"$addr\",status=\"exit_code\"\} $code
      else
        echo netcheck_http\{addr=\"$addr\",status=\"result\"\} 0
        echo netcheck_http\{addr=\"$addr\",status=\"exit_code\"\} $code
      fi
      shift 2
    ;;

  esac
done
