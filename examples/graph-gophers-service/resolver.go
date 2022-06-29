package main

type service struct {
	Name    string
	Version string
	Schema  string
}

type foo struct {
	Field1 string
}

type resolver struct {
	Service service
}

func newResolver() *resolver {
	return &resolver{
		Service: service{
			Name:    "graph-gophers-service",
			Version: "0.1",
			Schema:  schema,
		},
	}
}

func (r *resolver) Foo() (*foo, error) {
	return &foo{
		Field1: "some field1",
	}, nil
}
