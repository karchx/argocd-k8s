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
    | Bool, Bool -> Bool

    | Int, Int -> Int
    | Int, Long | Long, Int -> Long

    | (Int | Long) , Double | Double, (Int | Long) -> Double

    | Double, Double -> Double

    | _, _ -> String

let is_bool = function "true" | "false" -> true | _ -> false

let looks_float s =
    String.contains s '.' || String.exists ((=) 'e') s || String.exists ((=) 'E') s

let normalize s = String.trim s

let infer_value s =
    match s with
    | "" -> Null
    | s when is_bool s -> Bool
    | s when looks_float s -> Double 
    | s ->
         (match Int64.of_string_opt s with
         | Some i when (i >= Int64.of_int min_int && i <= Int64.of_int max_int) -> Int
         | Some _ -> Long
         | None -> String
         )

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
                    let v = normalize v in
                    acc.(i) <- promote acc.(i) (infer_value v))
                row
        in
        update first_row;
        List.iter update rest;
        acc

(* Generate schema for the data cleaning and transformation layer, usable in Spark. *)
(* Added support for and additional data source. *)
let sql_type_schema_spark = function
  | Bool -> "BooleanType"
  | Int -> "IntegerType"
  | Long -> "LongType"
  | Double -> "DoubleType"
  | String -> "StringType"
  | Null -> "StringType"
  | Date -> "DateType"

(* For PostgreSQL, insert data in string for complex type. *)
let sql_type_raw = function
  | Bool -> "BOOLEAN"
  | Int -> "TEXT"
  | Long -> "TEXT"
  | Double -> "TEXT"
  | String -> "TEXT"
  | Null -> "TEXT"
  | Date -> "DATE"

let generate_sql table headers schema =
    let cols =
        List.map2
            (fun h t -> Printf.sprintf " %s %s" h (sql_type_raw t))
            headers schema
        |> String.concat ",\n"
    in
    Printf.sprintf "CREATE TABLE IF NOT EXISTS %s (\n id UUID PRIMARY KEY DEFAULT uuidv7(),\n%s\n);" table cols

let generate_json_schema headers schema =
    let fields =
        List.map2
            (fun h t -> Printf.sprintf " \"%s\": \"%s\"" h (sql_type_schema_spark t))
            headers schema
        |> String.concat ",\n"
    in
    Printf.sprintf "{\n%s\n}" fields

let escape_sql s = String.concat "''" (String.split_on_char '\'' s)

let row_to_sql row =
    let escaped = List.map (fun v -> "'" ^ escape_sql v ^ "'") row in
    "(" ^ String.concat ", " escaped ^ ")"

let value_str rows = String.concat ", " (List.map row_to_sql rows)

let generate_insert_sql table columns rows = 
    let cols = String.concat ", " columns in
    let values = value_str rows in
    Printf.sprintf "INSERT INTO %s (%s) VALUES %s;" table cols values
