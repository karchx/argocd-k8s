let log_error ~max_len path err =
    let msg = Caqti_error.show err in
    let n = min max_len (String.length msg) in
    let truncated = String.sub msg 0 n in
    let oc =
        open_out_gen [Open_creat; Open_text; Open_append] 0o644 path
    in
    output_string oc (truncated ^ "\n");
    close_out oc

let write_file file_path content =
    Out_channel.with_open_bin file_path (fun oc ->
        output_string oc content;
        flush oc;
    ) 

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
 
