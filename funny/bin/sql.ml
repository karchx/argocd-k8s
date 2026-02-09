open Caqti_request
open Caqti_type
open Caqti_mult

let dynamic_sql sql =
    create
        ~oneshot:true
        unit
        unit
        zero
        (fun _di -> Caqti_query.of_string_exn sql)
