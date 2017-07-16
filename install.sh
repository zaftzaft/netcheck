cp netcheck.sh /opt/netcheck.sh
cd exporter
npm install -g
cd -

mkdir -p /etc/prometheus/netcheck/
cp ./config/external.json /etc/prometheus/netcheck/default.json
cp ./config/external.json /etc/prometheus/netcheck/external.json

cp ./systemd/netcheck_exporter.service /usr/lib/systemd/system/netcheck_exporter.service

systemctl daemon-reload
systemctl enable netcheck_exporter
systemctl start netcheck_exporter

