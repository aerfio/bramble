local namespace = 'bramble';

local deploy(name) = {
  kind: 'Deployment',
  apiVersion: 'apps/v1',
  metadata: {
    name: name,
    namespace: namespace,
    labels: {
      app: name,
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: name,
      },
    },
    template: {
      metadata: {
        labels: {
          app: name,
        },
      },
      spec: {
        containers: [
          {
            name: name,
            image: name + ':latest',
            imagePullPolicy: 'IfNotPresent',
          },
        ],
      },
    },
  },
};


local svc(name, targetPort=8080) = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: name,
    namespace: namespace,
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8080,
        targetPort: targetPort,
      },
    ],
    selector: {
      app: name,
    },
    type: 'ClusterIP',
  },
};


[
  {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: {
      name: namespace,
    },
  },
  deploy('gqlgen-service'),
  deploy('graph-gophers-service'),
  deploy('nodejs-service'),
  svc('gqlgen-service'),
  svc('graph-gophers-service'),
  svc('nodejs-service'),
  deploy('bramble') + {
    spec+: {
      template+: {
        spec+: {
          containers: [
            super.containers[0]
            {
              name: 'bramble',
              image: 'ghcr.io/movio/bramble:v1.4.1',
              command: ['/bramble'],
              args: [
                '-config',
                '/config/config.json',
              ],
              volumeMounts: [
                {
                  mountPath: '/config',
                  name: 'cfg',
                },
              ],
            },
          ],
          volumes: [{
            name: 'cfg',
            configMap: {
              name: 'bramble-cfg',
            },
          }],
        },
      },
    },
  },
  svc('bramble'),
  svc('bramble', 8081) + {
    metadata+: {
      name: 'bramble-admin',
    },
  },
  {
    kind: 'ConfigMap',
    apiVersion: 'v1',
    metadata: {
      name: 'bramble-cfg',
      namespace: namespace,
    },
    data: {
      'config.json': |||
        {
            "services": [
                "http://gqlgen-service:8080/query",
                "http://graph-gophers-service:8080/query",
                "http://nodejs-service:8080/query"
            ],
            "gateway-port": 8080,
            "private-port": 8081,
            "plugins": [
                {
                    "name": "playground"
                },
                {
                    "name": "admin-ui"
                }
            ]
        }
      |||,
    },
  },
  {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: 'bramble',
      namespace: namespace,
      annotations: {

      },
    },
    spec: {
      rules: [
        {
          http: {
            paths: [
              {
                pathType: 'Prefix',
                path: '/',
                backend: {
                  service: {
                    name: 'bramble',
                    port: {
                      number: 8080,
                    },
                  },
                },
              },
              {
                pathType: 'Prefix',
                path: '/admin',
                backend: {
                  service: {
                    name: 'bramble-admin',
                    port: {
                      number: 8080,
                    },
                  },
                },
              },
            ],
          },
        },
      ],
    },
  },

]
