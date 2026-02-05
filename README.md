# ArgoCD-k8s

this is project for multi discipline deployment using argocd and kubernetes.

## Project Diagram 

```
+----------------------+       +------------+       +---------------------+
| Producer script/app  | ----> | RabbitMQ   | ----> | Consumer Ingest     |
|  (OCaml/Python)      |       | Exchange   |       | (Scala -> bronze/)  |
+----------------------+       +------------+       +---------------------+
                                                                |
                                                                v
                                                    +-----------------------+
                                                    |  Local Filesystem     |
                                                    |  /data/datalake/      |
                                                    |                       |
                                                    |  bronze/ (raw)        |
                                                    |  silver/ (Delta)      |
                                                    |  gold/   (Delta)      |
                                                    |  _delta_log/          |
                                                    +-----------+-----------+
                                                                |
                                        +---------------------------+---------------------------+
                                        |                           |                           |
                              +---------v-----------+     +---------v---------+     +-----------v-----------+
                              | Spark Jobs          |     | Backend API       |     | Notif Consumer        |
                              | (Scala)             |     | (Go)              |     | (Erlang)              |
                              |                     |     |                   |     |                       |
                              | batch transform:    |     | query Delta       |     | read Delta changes    |
                              |  bronze -> silver   |     | serve REST API    |     | emit notifications    |
                              |  silver -> gold     |     +-------------------+     +-----------------------+
                              +---------------------+               |
                                                                    v
                                                          +---------+----------+
                                                          | Web/Mobile App     |
                                                          | (consume API)      |
                                                          +--------------------+
```

