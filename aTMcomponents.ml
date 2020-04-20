open Printf ;;
open Scanf ;;
  
module DB = Database3 ;; 

type id = int ;;

type action =
  | Balance           
  | Withdraw of int   
  | Deposit of int  
  | Next         
  | Finished      
;; 

type account_spec = {name : string; id : id; balance : int} ;;

let initialize (initial : account_spec list) : unit =
  initial
  |> List.iter (fun {name; id; balance}
                -> DB.create id name;
                   DB.update id balance) ;;

let rec acquire_id () : id =
  printf "Enter customer id: "; 
  try
    let id = read_int () in
    ignore (DB.exists id); id
  with
  | Not_found 
  | Failure _ -> printf "Invalid id \n";
                 acquire_id () ;;
                  
let rec acquire_amount () : int =
  printf "Enter amount: ";
  try
    let amount = read_int () in
    if amount <= 0 then raise (Failure "amount is non-positive");
    amount
  with
  | Failure _ -> printf "Invalid amount \n";
                 acquire_amount () ;;
  
let rec acquire_act () : action =
  printf "Enter action: (B) Balance (-) Withdraw (+) Deposit \
          (=) Done (X) Exit: %!";
  scanf " %c"
        (fun char -> match char with
                     | 'b' | 'B'        -> Balance
                     | '/' | 'x' | 'X'  -> Finished
                     | '='              -> Next
                     | 'w' | 'W' | '-'  -> Withdraw (acquire_amount ())
                     | 'd' | 'D' | '+'  -> Deposit (acquire_amount ())
                     | _                -> printf "  invalid choice\n";
                                           acquire_act () ) ;;

let get_balance : id -> int = DB.balance ;;

let get_name : id -> string = DB.name ;;

let update_balance : id -> int -> unit = DB.update ;;

let present_message (msg : string) : unit = printf "%s\n%!" msg ;;
  
let deliver_cash (amount : int) : unit =
  printf "Here's your cash: ";
  for _i = 1 to (amount / 20) do
    printf "[20 @ 20]"
  done;
  printf " and %d more\n" (amount mod 20) ;;

