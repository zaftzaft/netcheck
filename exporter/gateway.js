'use strict';

const child_process  = require("child_process");
const fs             = require("fs");
const path           = require("path");
const express        = require("express");
const ArgumentParser = require("argparse").ArgumentParser;
const exec           = child_process.exec;

const parser = new ArgumentParser({
  version: "0.1.0",
  addHelp: true,
  description: "netcheck_exporter"
});


parser.addArgument(["-n", "--netcheck-path"], {
  required: true
});

parser.addArgument(["-d", "--config-dir"], {
  required: true
});

parser.addArgument(["-p", "--port"], {
  help: "port number. default 9059"
});


const args = parser.parseArgs();

const app = express();


const PORT = args.port || process.env.NETCHECK_PORT || 9059;
const NETCHECK = args.netcheck_path;
const DEFAULT_CONFIG = "default.json";


app.get("/", (req, res) => {
  res.end(`<head><title>Netcheck Exporter</title></head>
    <body>
    <h1>Netcheck Exporter</h1>
    <p><a href="/metric">Metrics</a></p>
    </body>
    </html>
  `);
});

app.get("/metric", (req, res) => {

  const configName = (req.query.config || DEFAULT_CONFIG).split("/").pop().split(".")[0];
  const filename = path.join(args.config_dir, `${configName}.json`);

  console.log(filename);

  fs.readFile(filename, (err, data) => {
    if(err) {
      return res.status(500).end();
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

    exec(`sh ${NETCHECK} ${options.join(" ")}`, (err, stdout, stderr) => {
      if(err) {
        return res.status(500).end();
      }
      res.end(stdout);
    });

  });
});

app.listen(PORT, () => {
  console.log(`listen :${PORT}`);
  console.log(`netchcekPath: ${NETCHECK}`);
});

