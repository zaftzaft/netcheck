# dhcping: yaourt -S dhcping
# netcheck --dns google.com@8.8.8.8 --ping 8.8.8.8 --dhcp 192.168.0.1
#          --arping 192.168.1.1 --arping 172.16.0.100/eth1

VERSION=0.15

PING_TIMEOUT=3
PING_RETRY=1
HTTP_TIMEOUT=5
DHCP_TIMEOUT=3
DNS_TIMEOUT=3
ARPING_TIMEOUT=0.5

echo netcheck_version $VERSION

for OPT in "$@"
do
  case "$OPT" in
    --dns)
      {
        d=`echo $2 | sed -e "s/@/ /"`
        addr=`echo $d | cut -f1 -d " "`
        server=`echo $d | cut -f2 -d " "`

        res=`dig $addr A +timeout=$DNS_TIMEOUT @$server`
        if [ $? -eq 0 ];then
          echo netcheck_dns\{addr=\"$addr\",status=\"result\"\,nameserver=\"$server\"} 1
          qtime=`echo $res | grep "Query time: [0-9]*" -o | sed -e "s/Query time: //"`
          echo netcheck_dns\{addr=\"$addr\",status=\"time\"\,nameserver=\"$server\"} $qtime
        else
          echo netcheck_dns\{addr=\"$addr\",status=\"result\"\,nameserver=\"$server\"} 0
        fi
      } &

      shift 2
    ;;

    --ping)
      {
        addr=$2
        res=`ping -c $PING_RETRY $addr -w $PING_TIMEOUT`

        if [ $? -eq 0 ]; then
          rtt=`echo $res | grep "time=[0-9]*.[0-9]*" -o | sed -e "s/time=//"`
          rtt=`echo $rtt | sed -e "s/^.* //"`
          echo netcheck_ping\{addr=\"$addr\",status=\"result\"\} 1
          echo netcheck_ping\{addr=\"$addr\",status=\"rtt\"\} $rtt
        else
          echo netcheck_ping\{addr=\"$addr\",status=\"result\"\} 0
          echo netcheck_ping\{addr=\"$addr\",status=\"rtt\"\} -1
        fi
      } &

      shift 2
    ;;

    #--dhcp)
    #  addr=$2
    #  res=`dhcping -t $DHCP_TIMEOUT -s $addr -q`
    #  code=$?

    #  if [ $code -eq 0 ]; then
    #    echo netcheck_dhcp\{addr=\"$addr\",status=\"result\"\} 1
    #    echo netcheck_dhcp\{addr=\"$addr\",status=\"exit_code\"\} $code
    #  else
    #    echo netcheck_dhcp\{addr=\"$addr\",status=\"result\"\} 0
    #    echo netcheck_dhcp\{addr=\"$addr\",status=\"exit_code\"\} $code
    #  fi

    #  shift 2
    #;;

    --http)
      {
        addr=$2
        res=`curl --silent -w '%{http_code}\n' -o /dev/null $addr --connect-timeout $HTTP_TIMEOUT`
        code=$?
        if [ $code -eq 0 ]; then
          echo netcheck_http\{addr=\"$addr\",status=\"result\"\} 1
          echo netcheck_http\{addr=\"$addr\",status=\"exit_code\"\} $code
          echo netcheck_http\{addr=\"$addr\",status=\"status_code\"\} $res
        else
          echo netcheck_http\{addr=\"$addr\",status=\"result\"\} 0
          echo netcheck_http\{addr=\"$addr\",status=\"exit_code\"\} $code
        fi
      } &

      shift 2
    ;;


    --arping)
      {
        opt=""
        if [ `echo $2 | grep "/"` ]; then
          addr=`echo $2 | cut -f 1 -d "/"`
          dev=`echo $2 | cut -f 2 -d "/"`
          opt="-I $dev"
        else
          addr=$2
        fi

        res=`arping $addr -f -c 1 -w $ARPING_TIMEOUT $opt`
        code=$?

        if [ $code -eq 0 ]; then
          mac=`echo $res | grep -o "\[.*\]" | sed -e "s/\[//" -e "s/\]//"`
          echo netcheck_arping\{addr=\"$addr\",status=\"result\"\} 1
          echo netcheck_arping\{addr=\"$addr\",status=\"mac\"\,mac=\"$mac\"} 1
        else
          echo netcheck_arping\{addr=\"$addr\",status=\"result\"\} 0
        fi
      } &

      shift 2
    ;;


  esac
done


wait
