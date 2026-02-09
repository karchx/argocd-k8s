let parse_csv file_path =
    let lines = In_channel.with_open_text file_path In_channel.input_all
        |> String.split_on_char '\n'
        |> List.filter (fun line -> line <> "" && not (String.contains line '#')) in
    match lines with
    | [] -> raise (Failure "Empty CSV")
    | headers_line :: rows_lines ->
        let headers = String.split_on_char ',' headers_line in
        let rows = List.map (String.split_on_char ',') rows_lines in
        (headers, rows)
 
