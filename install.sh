cp netcheck.sh /opt/netcheck.sh
cd exporter
npm install -g
cd -

cp ./systemd/netcheck_exporter.service /usr/lib/systemd/system/netcheck_exporter.service

systemctl daemon-reload
systemctl enable netcheck_exporter
systemctl start netcheck_exporter

