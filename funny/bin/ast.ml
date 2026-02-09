type dtype = 
    | Null
    | Bool
    | Int
    | Long
    | Double
    | String
    | Date


let promote a b =
    match a, b with
    | Null, x | x, Null -> x
    | Int, Int -> Int
    | Int, Long | Long, Int -> Long
    | (Int | Long) , Double | Double, (Int | Long) -> Double
    | Bool, Bool -> Bool
    | _, _ -> String

let infer_value s =
    if s = "" then Null
    else if s = "true" || s = "false" then Bool
    else
       try
        let i = Int64.of_string s in
        if i >= Int64.of_int min_int && i <= Int64.of_int max_int
        then Int else Long
       with _ ->
            try
                ignore (float_of_string s);
                Double
            with _ ->
                String

let infer_schema rows =
    (*let cols = List.transpose rows in*)
    match rows with
    | [] -> [||]
    | first_row :: rest ->
        let n = List.length first_row in
        let acc =  Array.make n Null in
        let update row =
            List.iteri 
                (fun i v -> 
                    acc.(i) <- promote acc.(i) (infer_value v))
                row
        in
        update first_row;
        List.iter update rest;
        acc

let sql_type = function
  | Bool -> "BOOLEAN"
  | Int -> "INTEGER"
  | Long -> "BIGINT"
  | Double -> "FLOAT8"
  | String -> "TEXT"
  | Null -> "TEXT"
  | Date -> "DATE"

let generate_sql table headers schema =
    let cols =
        List.map2
            (fun h t -> Printf.sprintf " %s %s" h (sql_type t))
            headers schema
        |> String.concat ",\n"
    in
    Printf.sprintf "CREATE TABLE IF NOT EXISTS %s (\n%s\n);" table cols


let escape_sql s = String.concat "''" (String.split_on_char '\'' s)

let row_to_sql row =
    let escaped = List.map (fun v -> "'" ^ escape_sql v ^ "'") row in
    "(" ^ String.concat ", " escaped ^ ")"

let value_str rows = String.concat ", " (List.map row_to_sql rows)

let generate_insert_sql table columns rows = 
    let cols = String.concat ", " columns in
    let values = value_str rows in
    Printf.sprintf "INSERT INTO %s (%s) VALUES %s;" table cols values
