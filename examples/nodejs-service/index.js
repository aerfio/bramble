var express = require("express");
var { graphqlHTTP } = require('express-graphql');
var { buildSchema } = require("graphql");
var fs = require("fs").promises;
const bodyParser = require("body-parser")

const defaultPort = 8080;

async function setup() {
  let schemaSource = await fs.readFile("schema.graphql", "utf-8");
  let schema = buildSchema(schemaSource);

  let resolver = {
    service: {
      name: "nodejs-service",
      version: "1.0.0",
      schema: schemaSource,
    },
    session: (arg) => {
      console.log(arg)
      return {
        id: arg.id,
        policy: `${arg.id}-policy`,
        nwi: "some-nwi",
        ipfix: {
          enabled: arg.id === "123456"
        },
        ipfff: arg.id === "123457" ? "ipfff" : null
      }
    }
  };

  let app = express();
  app.use(bodyParser());
  app.use((req, res, next) => {
    console.log(req.body); // this is what you want

    next()
  });
  app.use(
    "/query",
    graphqlHTTP({
      schema: schema,
      rootValue: resolver,
      graphiql: true,
    })
  );

  app.use('/health', (req, res) => {
    res.send('OK')
  });

  return app;
}

(async () => {
  try {
    let app = await setup();
    let port = process.env.PORT;
    if (port === undefined) {
      port = defaultPort;
    }
    app.listen(port, () =>
      console.log(`example nodejs-service running on http://localhost:${port}/`)
    );
  } catch (e) {
    console.log(e);
  }
})();
