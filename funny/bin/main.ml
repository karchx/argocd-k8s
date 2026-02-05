open Lwt.Infix
open Caqti_request

let connect_to_db uri =
  let uri = Uri.of_string uri in
  Caqti_lwt_unix.connect uri

let create_customer_table (module Db : Caqti_lwt.CONNECTION) =
  Db.exec Queries.create_customer_table ()

let insert_asteroid (module Db : Caqti_lwt.CONNECTION) name discovery_date =
  Db.exec Queries.insert_asteroid (name, discovery_date)

let () =
  Lwt_main.run (
    let db_uri = "postgresql://myuser:mypassword@127.0.0.0:5432/mydatabase" in
    
    match%lwt connect_to_db db_uri with
    | Ok connection ->
        Printf.printf "Successfully connected to the database!\n";
        (match%lwt create_customer_table connection with
        | Ok () ->
            Printf.printf "Asteroids table created successfully (if it did not exist).\n";
            let name = "Halley's Comet" in
            let discovery_date = Some (Unix.(gmtime (time ()))) in
            (match%lwt insert_asteroid connection name discovery_date with
            | Ok () ->
                Printf.printf "Inserted asteroid: %s\n" name;
            Lwt.return_unit
        | Error err ->
            failwith (Caqti_error.show err))
    | Error err ->
        failwith (Caqti_error.show err)
  )
