'use strict';

const Hapi = require('@hapi/hapi');

const init = async () => {

  const server = Hapi.server({
    port: 3000
  });

  server.route({
    method: 'GET',
    path: '/',
    options: {
      validate: {
        query: false,
        failAction: async (request, h, err) => { throw err; }
      }
    },
    handler: (request, h) => {
      return 'Hello from k8s poseidon v2';
    }
  });

  server.route({
    method: 'GET',
    path: '/healthz',
    options: {
      validate: {
        query: false,
        failAction: async (request, h, err) => { throw err; }
      }
    },
    handler: (request, h) => {
      return 'OK';
    }
  });

  await server.start();
  console.log('Server running on %s', server.info.uri);
};

process.on('unhandledRejection', (err) => {

  console.log(err);
  process.exit(1);
});

init();