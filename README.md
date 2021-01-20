Spreadsheets have many uses, but their primary task is computation on tables — data that are organized into rows and columns. This is a data abstraction that enables us to compute with csv tables in OCAML.

Operations. Here are the rest of the operations I want to perform on tables:
- Empty: Create an empty table, which has no rows and no columns.
- Add: Add a new column by providing both its label, and all of the data for it as a list. The column becomes the last column of the table.
• Get: Get all the data from a column as a list.
• Drop: Remove a column.
• Sort: Sort the table by a column in ascending order.
• Sort Descending: Sort the table by a column in descending order.
• Map: Apply a single-argument function to a column, producing a new list of data.
• Map2: Apply a two-argument function to two columns, producing a new list of data.
• Filter: Filter the table by keeping all its columns but only some rows. Which rows to keep is determined by a predicate of a column. (A predicate is a function from a single data value to bool, like the function argument of List.filter.) For example, I might want to filter the assignment table to keep all rows where the score on A1 is between 0 and 10, or filter the vote table to keep all rows from the state of Indiana.
