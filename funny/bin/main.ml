open Lwt.Infix
open Caqti_request

let connect_to_db uri =
  let uri = Uri.of_string uri in
  Caqti_lwt_unix.connect uri

let create_asteroids_table (module Db : Caqti_lwt.CONNECTION) (sql : string) =
  Db.exec (Sql.dynamic_sql sql) ()

let insert_asteroid (module Db : Caqti_lwt.CONNECTION) (sql : string) =
  Db.exec (Sql.dynamic_sql sql) ()

let () =
  Lwt_main.run (
    let db_uri = "postgresql://myuser:mypassword@127.0.0.1:5432/mydatabase" in
    let open Lwt.Syntax in
    let* conn_res = connect_to_db db_uri in
    match conn_res with
    | Error err -> Lwt.fail (Failure (Caqti_error.show err))
    | Ok conn ->
        let headers, rows = Fs.parse_csv "../source/PSCompPars_2026.02.07_16.31.28.csv" in
        (* let headers, rows = Fs.parse_csv "../source/test.csv" in *)
        let schema = Ast.infer_schema rows |> Array.to_list in
        let create_sql = Ast.generate_sql "asteroids" headers schema in
        let insert_sql = Ast.generate_insert_sql "asteroids" headers rows in
        let schema_spark = Ast.generate_json_schema headers schema in
        Fs.write_file "schema_spark.json" schema_spark;
        let* _ = create_asteroids_table conn create_sql in
        Printf.printf "Table created successfully.\n";
        let* insert_res = insert_asteroid conn insert_sql in
        match insert_res with
        | Error err -> 
            Fs.log_error ~max_len:5000 "error.log" err;
            Lwt.fail (Failure ("error inserting data: "))
        | Ok () ->
            Printf.printf "Data inserted successfully.\n";
            Lwt.return ()
  )

