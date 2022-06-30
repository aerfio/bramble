# Example

To start example please read [Running locally](../README.md#running-locally) section of root `README.md` file.
Then go to `http://localhost:8082/playground` or `http://localhost:8083/admin` - additional plugins than enable those views have been additionally enabled.

# Kubernetes deploy

Please start kind cluster using `kindingress.sh` script and then use commands in [Makefile](./Makefile) to build container images, load them into kind cluster and apply needed k8s resources.
