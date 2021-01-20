open OUnit2
open Table

(**********************************************************************)
(* Provided helper functions *)
(**********************************************************************)

(** [pp_string s] pretty-prints string [s]. *)
let pp_string s = "\"" ^ s ^ "\""

(** [pp_list pp_elt lst] pretty-prints list [lst], using [pp_elt]
    to pretty-print each element of [lst]. *)
let pp_list pp_elt lst =
  let pp_elts lst =
    let rec loop n acc = function
      | [] -> acc
      | [h] -> acc ^ pp_elt h
      | h1 :: (h2 :: t as t') ->
        if n = 100 then acc ^ "..."  (* stop printing long list *)
        else loop (n + 1) (acc ^ (pp_elt h1) ^ "; ") t'
    in loop 0 "" lst
  in "[" ^ pp_elts lst ^ "]"

(**********************************************************************)
(* Test suite *)
(**********************************************************************)

(** [display_printer] is a function suitable for passing 
    as the [~printer] argument of [assert_equal] when testing
    the Display operation. *)
let display_printer : string list list -> string = 
  pp_list (pp_list pp_string)


let display_test name file_name
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (Table.read file_name |> Table.display));;

let add_row_test name table col_label data
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (Table.add table col_label data |> Table.display));;

let empty_test name
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (Table.empty |> Table.display));;

let get_test name col_name table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (table |> Table.get col_name));;

let drop_test name col_name table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (table |> Table.drop col_name |> Table.display));;

let sort_test name col_name table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (table |> Table.sort col_name |> Table.display));;

let sort_desc_test name col_name table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (table |> Table.sortDescending col_name |> Table.display));;

let map_test name col_name func table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (table |> Table.map col_name func));;

let map2_test name col1_name col2_name func table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (table |> Table.map2 col1_name col2_name func));;

let write_test name file_name table
    expected_output : test = 
  name >:: (fun _ -> assert_equal expected_output 
               (let _ = table |> Table.write file_name 
                in Table.read file_name |> display));;


let assignments = [["NetID"; "a1"; "a2"]; ["aaa0"; "50."; "66.7"]; 
                   ["bbb1"; "0."; "80."];["ccc2"; "90."; "102."]]

let votes = [["State"; "City"; "Votes for Alice"; "Votes for Bob"];
             ["Unnamed"; "Capital City"; "3016."; "2593."];
             ["Indiana"; "Pawnee"; "2148."; "7999."];
             ["Maine"; "Ordinary"; "463."; "1954."]]

let empty_table = Table.empty
let col_names = Table.add empty_table "name" 
    [StringField "Maidul"; StringField "Bob";]
let col_years = Table.add col_names "year" 
    [FloatField 1001.; FloatField 1000.]
let col_fav_color = Table.add col_years "fav letter" 
    [StringField "X"; StringField "A"]
let col_fav_num = Table.add col_fav_color "fav num" 
    [FloatField 1.; FloatField 2.]

let get_float element =
  match element with
  | FloatField x -> x 
  | _ -> failwith "not a float"

let add a b = (FloatField (get_float a +. get_float b))


let tests = [
  display_test "Check the string output of table" "assignments.csv" assignments;
  display_test "Check the string output of table" "votes.csv" votes;
  empty_test "empty test" [];
  add_row_test "add one row of data to empty table" empty_table "name" 
    [StringField "Maidul"; StringField "Bob";] [["name"]; ["Maidul"]; ["Bob"]];

  add_row_test "add one row of data to none empty table" col_names "year" 
    [FloatField 1001.; FloatField 1000.;] 
    [["name"; "year"]; ["Maidul"; "1001."]; ["Bob"; "1000."]];

  get_test "get all data for name colum" "name" 
    col_names [StringField "Maidul"; StringField "Bob";];

  drop_test "drop name" "name" col_years [["year"]; ["1001."]; ["1000."]];

  sort_test "sort by number" "year" col_years 
    [["name"; "year"]; ["Bob"; "1000."]; ["Maidul"; "1001."]];

  sort_test "sort by string" "fav letter" col_fav_color 
    [["name"; "year"; "fav letter"]; ["Bob"; "1000."; "A"];
     ["Maidul"; "1001."; "X"]];

  sort_desc_test "sort desc by string" "fav letter" 
    col_fav_color [["name"; "year"; "fav letter"]; ["Maidul"; "1001."; "X"];
                   ["Bob"; "1000."; "A"]];

  sort_desc_test "sort desc by float" "year" 
    col_fav_color [["name"; "year"; "fav letter"]; ["Maidul"; "1001."; "X"];
                   ["Bob"; "1000."; "A"]];

  map_test "map every number to 2." "year" (fun x-> FloatField 2.) col_fav_color 
    [FloatField 2.; FloatField 2.];

  map2_test "add colum year and fav_num " "year" "fav num" 
    (fun a1 a2 -> add a1 a2 ) col_fav_num [FloatField 1002.; FloatField 1002.];

  write_test "write file to drive" "test_write.csv" col_fav_num 
    (Table.read "test_write.csv" |> Table.display)
]

let suite = "suite" >::: tests

let _ = run_test_tt_main suite
