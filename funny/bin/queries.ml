open Caqti_template.Create

let create_customer_table =
    direct T.(unit -->. unit)
    {eos|
        CREATE TABLE IF NOT EXISTS asteroids (
            id SERIAL PRIMARY KEY,
            name TEXT NOT NULL,
            discovery_date DATE
        )
    |eos}

let insert_asteroid =
    static T.(string -> date -->. unit)
    "INSERT INTO asteroids (name, discovery_date) VALUES (?, ?)"
