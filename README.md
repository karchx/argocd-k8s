```
/root/
├── cmd/
│   ├── auth/              # main de auth service
│   │   └── main.go
│   ├── order/              # main de user service
│   │   └── main.go
│   └── gateway/           # si tenés un API gateway
│       └── main.go
│
├── internal/
│   ├── auth/              
│   │   ├── handler/       # HTTP handlers
│   │   ├── service/       # business logic 
│   │   ├── store/         # interface + implementation (e.g. postgres)
│   │   └── model/         # structs, DTOs, custom errors
│   │
│   ├── order/             # the same
│   │   ├── handler/
│   │   ├── service/
│   │   ├── store/
│   │   └── model/
│   │
│   └── common/            
│       ├── logger/        # logger (zap, zerolog, l-og)
│       ├── config/        # config loader (env, flags, etc)
│       ├── middleware/    # middlewares (auth, logging)
│       ├── db/            # connection database
│       └── utils/      
│
├── pkg/
│   ├── jwt
│   ├── hash/
│   └── email/
│
├── api/
│   ├── proto/             # gRPC? (protofiles)
│   ├── openapi/           # OpenAPI specs
│   └── contracts/         # frontend/backend
│
├── deployments/
│   ├── docker/            # Dockerfiles
│   └── k8s/               # K8s manifest
│
├── tests/  
│   └── e2e/
│
├── Makefile               # commands (build, lint, test)
├── go.mod
└── README.md
```
