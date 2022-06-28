local namespace = 'cdp-docs';

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


local svc(name) = {
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
        targetPort: 8080,
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
  {
    kind: 'ConfigMap',
    apiVersion: 'v1',
    metadata: {
      name: 'bramble-cfg',
      namespace: namespace,
    },
    data: {
      description: |||
        The Tom Collins is essentially gin and
        lemonade.  The bitters add complexity.
      |||,
    },
  },
]
