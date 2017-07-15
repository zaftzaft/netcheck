'use strict';

const child_process = require("child_process");
const fs = require("fs");
const express = require("express");
const exec = child_process.exec;

const app = express();

const PORT = process.env.NETCHECK_PORT || 9059;


app.get("/", (req, res) => {
  res.end(`<head><title>Netcheck Exporter</title></head>
    <body>
    <h1>Netcheck Exporter</h1>
    <p><a href="/metric">Metrics</a></p>
    </body>
    </html>`);
});

app.get("/metric", (req, res) => {
  fs.readFile("./external.json", (err, data) => {
    if(err) {
      res.status(500).end();
    }
    const config = JSON.parse("" + data);
    let options = [];

    const builder = (checker, opt) => {
      (config[checker]||[]).forEach(arg => {
        options.push(`${opt} ${arg}`);
      });
    }

    builder("ping", "--ping");
    builder("dns", "--dns");
    builder("dhcp", "--dhcp");
    builder("http", "--http");

    //console.log(`sh ../netcheck.sh ${options.join(" ")}`);
    exec(`sh ../netcheck.sh ${options.join(" ")}`, (err, stdout, stderr) => {
      if(err) {
        res.status(500).end();
      }
      res.end(stdout);
    });

  });
});

app.listen(PORT, () => {
  console.log(`listen :${PORT}`);
});

