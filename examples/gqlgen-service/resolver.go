package main

import (
	"context"
	"fmt"
	"math/rand"
	"strconv"
	"strings"

	"github.com/vektah/gqlparser/v2/formatter"
	"github.com/vektah/gqlparser/v2/gqlerror"
	"k8s.io/utils/pointer"
)

type Resolver struct{}

func (r *Resolver) Query() QueryResolver {
	return &queryResolver{r}
}

type queryResolver struct{ *Resolver }

// Bar implements QueryResolver
func (*queryResolver) Bar(ctx context.Context, id string) (*Bar, error) {
	fmt.Println(id)
	if id == "1" {
		return &Bar{
			ID:              id,
			AdditionalField: pointer.String("SomeAdditionalField"),
		}, nil
	}
	if id == "2" {
		return &Bar{
			ID: id,
		}, nil
	}
	return nil, gqlerror.Errorf("some err lol")
}

var _ QueryResolver = &queryResolver{}

func (r *queryResolver) Service(ctx context.Context) (*Service, error) {
	s := new(strings.Builder)
	f := formatter.NewFormatter(s)
	// parsedSchema is in the generated code
	f.FormatSchema(parsedSchema)

	service := Service{
		Name:    "gqlgen-service",
		Version: "0.1.0",
		Schema:  s.String(),
	}
	return &service, nil
}

func (r *queryResolver) Foo(ctx context.Context, id string) (*Foo, error) {
	foo := Foo{
		ID:     id,
		Gqlgen: true,
	}
	return &foo, nil
}

func (r *queryResolver) RandomFoo(ctx context.Context) (*Foo, error) {
	id := strconv.Itoa(rand.Intn(100))
	foo := Foo{
		ID:     id,
		Gqlgen: true,
	}
	return &foo, nil
}
