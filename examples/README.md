# Example

To start example run:
```bash
cd nodejs-service && npm install && cd ..
cd gqlgen-service && make generate && cd ..
```
Next run those commands in 3 different terminal tabs:
- `cd gqlgen-service && PORT=8080 go run .`
- `cd nodejs-service && PORT=8081 npm start`
- `cd graph-gophers-service && PORT=8082 go run .`

Finally run Bramble:
```bash
cd .. # go to the root of repo
go run ./cmd/bramble/main.go -conf ./examples/cfg.json
```

# Kubernetes deploy

Please start kind cluster using `kindingress.sh` script and then use commands in [Makefile](./Makefile) to build container images, load them into kind cluster and apply needed k8s resources.
