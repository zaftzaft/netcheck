which node
if [ ! $? -eq 0 ]; then
  echo "[E] nodejs is not installed"
  exit 1
fi

which npm
if [ ! $? -eq 0 ]; then
  echo "[E] npm is not installed"
  exit 1
fi



cp netcheck.sh /opt/netcheck.sh
cd exporter
npm install -g
cd -

if [ ! -d /etc/prometheus/netcheck/ ]; then
  mkdir -p /etc/prometheus/netcheck/
  cp ./config/external.json /etc/prometheus/netcheck/default.json
  cp ./config/external.json /etc/prometheus/netcheck/external.json
fi




systemctl is-enabled netcheck_exporter
if [ $? -eq 0 ]; then
  systemctl stop netcheck_exporter
fi

if [ -d /usr/lib/systemd/system/ ]; then
  cp ./systemd/netcheck_exporter.service /usr/lib/systemd/system/netcheck_exporter.service
else
  cp ./systemd/netcheck_exporter.service /etc/systemd/system/netcheck_exporter.service
fi


systemctl daemon-reload
systemctl enable netcheck_exporter
systemctl start netcheck_exporter


