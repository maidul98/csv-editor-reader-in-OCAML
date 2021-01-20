(************************************************************ 
   Copyright (C) 2020 Cornell University.
   Created by Michael Clarkson (mrc26@cornell.edu) and CS 3110 course staff.
   You may not redistribute this exam, distribute any derivatives,
   or use it for commercial purposes.
 ************************************************************) 

(** CS 3110 Fall 2020 Semi-Final
    @author Maidul Islam (mi252) *)

(************************************************************ 

   Academic Integrity Statement

   I, the person named in the @author comment above, have fully reviewed the
   course academic integrity policies, and the instructions document for this
   exam.  I acknowledge that the minimum penalty for cheating on this exam
   is a score of -100%.  I acknowledge that no collaboration is permitted,
   nor is use of sites such as Chegg.

   If there are any violations I want to admit, I have documented them here,
   or I will send them by email to the professor:

   - none

 ************************************************************)  

(** Is the abstract type which represents a excel table *)
type t

type element = FloatField of float | StringField of string

(** [read] Given a file name, will return convert it to a table *)
val read : string -> t

(** [display] Give a table, will return a string list list where the first 
    element of the outer list will be the labels. 
    The remaining elements of the outer list will be the rows, in their proper 
    order. The inner list will be the cells of each row, in their proper order. 
    If the table is empty, it will display as []. *)
val display : t -> string list list

(** [empty] Will return a empty table with no rows and no colums *)
val empty : t

(** Will add a new colum to the table [table] with the label [col_label] and 
    the list of data [data] to each row under this new colum. This colum will be 
    added in the far right position *)
val add : t -> string -> element list -> t

(** [get] will return all colum data from the colum matching [col_name] 
    from table [table]*)
val get : string -> t -> element list

(** [drop] will remove all cells with the colum name [col_name] from the table 
    [table] and return the new table without that colum. *)
val drop : string -> t -> t

(** [sort] will sort the table [table] rows using the colum [col_name] in 
    ascending order. If the colum to be started is of type Float, 
    [Float.compare] will be used for compaering otherise [String.compare] will
    be used.*)
val sort : string -> t -> t 

(** [sortDescending] uses [sort] on the colum [col_name] in the table [table]
    but reverses the result so that the resulting table is soarted in 
    descending order *)
val sortDescending : string -> t -> t 

(** [map] Will apply function [func] to each data in colum [col_name] of the 
    table [table] and return this resulting data as a list.*)
val map : string -> (element -> element) -> t -> element list

(** [map2] will apply the function [func] to two colum data, [col_name1] and 
    [col_name2] and return this resulting data as a list.*)
val map2 : string -> string -> (element -> element -> element) -> 
  t -> element list

(** [write] will save save the table [table] on the current working directory
    as a .csv file under the name [file_name].
    Requires: file name must have .csv extension   *)
val write : string -> t -> unit 

(**[filter] Will filter a table [table] along the colum [colum_num] such that 
   if result of applying [func] returns true then the row will be kept, 
   otherwise the whole row will be discarted. The resultant table is returned.*)
val filter : string -> (element -> bool) -> t -> t



