package main

import (
	"context"
	"log"
	"strings"

	"github.com/vektah/gqlparser/v2/formatter"
)

type Resolver struct{}

func (r *Resolver) Query() QueryResolver {
	return &queryResolver{r}
}

type queryResolver struct{ *Resolver }

// SessionForImsi implements QueryResolver
func (qr *queryResolver) SessionForImsi(ctx context.Context, imsi string) (*Session, error) {
	log.Println(imsi)
	return qr.Session(ctx, imsi)
}

var _ QueryResolver = &queryResolver{}

// Session implements QueryResolver
func (*queryResolver) Session(ctx context.Context, id string) (*Session, error) {
	log.Println(id)
	if id == "123456" {
		return &Session{
			ID:   id,
			Imsi: id,
		}, nil
	}
	return &Session{
		ID:           id,
		Imsi:         id,
		SomeImsiData: ptr("Some Additional Data"),
	}, nil
}

func ptr[T any](arg T) *T {
	return &arg
}

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
