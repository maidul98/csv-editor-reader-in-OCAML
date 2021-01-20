
type element = FloatField of float | StringField of string

(** 
   AF: A table represented as a list of list of tuples where each inner list  
   represents a row in the the table. Each tuple in the inner list,
   [(c1, d1), (c2, d2)...] represents a cell in the table where c1 is the colum 
   name and d1 is the corresponding data in that colum-row.

   RI: The table must not conatin any empty cells. The table can only represent 
   ASCII values. If a single cell in a colum cannot be turned to a float, all
   cells in that colum will be of type string, otherwise float.
*)
type t = (string * element) list list 

let can_be_float string_data = 
  try
    let _ = float_of_string string_data in true 
  with _ -> false 

let float_or_string element = match element with 
  | FloatField _ -> true 
  | StringField _ -> false 

(** Will try to change each item to a type float otherwise to string *)
let rec inital_pass row  = 
  match row with 
  | [] -> []
  | (header, data)::tail -> if can_be_float data
    then (header, FloatField (float_of_string data) )::(inital_pass tail) 
    else (header, StringField data)::(inital_pass tail)

(** Given a cell in the table, check if it is a float or not*)
let is_float cell = 
  match cell with 
  | FloatField _ -> true 
  | StringField _ -> false 

(** Give a col title [header] and an table, it will check it all data 
    type of that column should be strings or floats *)
let col_data_types col_title_match associate_data = 
  let concat_assoc_list = associate_data |> List.concat in 
  let filtered_data = 
    concat_assoc_list |> List.filter (fun (col_title, data) -> 
        col_title = col_title_match) in 
  filtered_data |> List.map (fun (col_title, data) -> 
      if is_float data then "float" else "string") 
  |> List.mem "string" 
  |> (fun x -> if x = true then (col_title_match, "string") 
       else (col_title_match, "float") )

(** [change_cell_type] will change the data [data] of colum titel [col_title] 
    to the corssposding colum type [col_type] *)
let change_cell_type col_title col_type data = 
  match data with 
  | StringField text -> if col_type = "string" then (col_title, data) else 
      (col_title, (FloatField (float_of_string text)) )
  | FloatField text -> if col_type = "float" then (col_title, data) else 
      (col_title, (StringField (string_of_float text)) )

(** Will change the type of a col title to the type spefied in [col_type*)
let modify col_title_match associate_data col_type = 
  associate_data 
  |> List.map (fun row -> row |> List.map (fun (col_title, cell_data) -> 
      if col_title_match == col_title then 
        change_cell_type col_title col_type cell_data  
      else (col_title, cell_data) ))

(** Change col type for each colum *)
let rec loop_over_header_types ass_list col_types = match col_types with 
  | [] -> ass_list
  | (col_title, col_data_type)::tail -> 
    loop_over_header_types (modify col_title ass_list col_data_type) tail

(** Explain *)
let read file_name = 
  let csv = Csv.load file_name  in 
  let headers = csv |> List.hd in 
  let data = csv |> List.tl in 
  let csv_parsed = Csv.associate headers data |> List.map inital_pass in 
  let col_types = headers |> List.map 
                    (fun col_title -> col_data_types col_title csv_parsed) 
  in loop_over_header_types csv_parsed col_types

let get_key row = match row with 
  |  (header, element) -> header

let row_to_string row = match row with 
  | (header, element) -> begin 
      match element with 
      | FloatField data -> string_of_float data
      | StringField data -> data
    end 

let display (t: t) = 
  let header = t |> List.hd |> List.map (fun row -> get_key row ) in 
  let dataValues = t |> List.map (fun row -> List.map row_to_string row ) in  
  let result = header::dataValues in if result = [[];[]] then [] else result

let empty = [[]]

let rec make_empty_lists n =
  match n with 
  | 1 -> [[]]
  | _ -> []::(make_empty_lists (n-1) )

let get_same_length new_data_list table_list = 
  if List.length table_list < List.length new_data_list 
  then make_empty_lists (List.length new_data_list) else table_list

let add (table: t) (col_label : string) (data : element list) = 
  let tupes = data |> List.map (fun data -> (col_label, data) ) in 
  let combin = List.combine tupes (get_same_length tupes table) in 
  combin |> List.map (fun (new_item, row) -> row@[new_item])

let get col_name (table: t) = 
  let colum = table |> List.map 
                (fun row -> row |> List.filter 
                              (fun (col_title, data) -> 
                                 col_title = col_name) ) in 
  colum |> List.concat |> List.map (fun (_, data) -> data)

let drop col_name (table : t) = 
  table |> List.map 
    (fun row -> row |> 
                List.filter (fun (col_title, data) -> col_title <> col_name))

let get_float_from_element element = match element with 
  | FloatField x -> x 
  | _ -> failwith "Not a float"

let get_get_string_from_element element = match element with 
  | StringField x -> x 
  | _ -> failwith "Not a float"

let sort_rows_by_float (col_name: string) row1 row2 = 
  let number1 = List.assoc col_name row1 |> get_float_from_element in 
  let number2 = List.assoc col_name row2 |> get_float_from_element in 
  Float.compare number1 number2

let sort_rows_by_alpha (col_name: string) row1 row2 = 
  let string1 = List.assoc col_name row1 |> get_get_string_from_element in 
  let string2 = List.assoc col_name row2 |> get_get_string_from_element in 
  String.compare string1 string2


let sort col_name (table: t) = match List.assoc col_name (List.hd table) with 
  | FloatField data -> List.sort (sort_rows_by_float col_name) table 
  | StringField data -> List.sort (sort_rows_by_alpha col_name) table 


let sortDescending col_name (table: t) = 
  table |> sort col_name |> List.rev

let map col_name func (table : t) = 
  table |> get col_name |> List.map (fun element -> func element)

let map2 col_name1 col_name2 func (table : t) = 
  let list1 = get col_name1 table in 
  let list2 = get col_name2 table in 
  List.map2 (fun arg1 arg2 -> func arg1 arg2) list1 list2

let write (file_name : string) (table : t) =
  table |> display |> Csv.save file_name

let check_predicate row col_name func = match List.assoc col_name row with 
  | data -> func data

let filter (col_name: string) func (table : t) = 
  table |> List.filter ( fun row -> if (check_predicate row col_name func) 
                         then true else false)







