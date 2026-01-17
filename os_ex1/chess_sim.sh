#!/usr/bin/env bash
if [ "${BASH_VERSINFO:-0}" -lt 5 ]; then
  #for mac with Homebrew - personal issue
  if [ -x /opt/homebrew/bin/bash ]; then
    exec /opt/homebrew/bin/bash "$0" "$@"
  else
    echo "Error: Bash >=5 required. Install with Homebrew: brew install bash" >&2
    exit 1
  fi
fi

#init the chess board to the starting position
initialize_board() {
    current_move=0

    #fill middle rows with dots
    for ((i=2;i<6;i++)); do
        for((j=0;j<8;j++)); do
            board["$i,$j"]="."
        done
    done
    for((i=0;i<8;i++)); do
        case $i in
        0|7)
            board["7,$i"]="R"
            board["0,$i"]="r" ;;
        1|6)
            board["7,$i"]="N"
            board["0,$i"]="n" ;;
        2|5)
            board["7,$i"]="B"
            board["0,$i"]="b" ;;
        3)
            board["7,$i"]="Q"
            board["0,$i"]="q" ;;
        4)
            board["7,$i"]="K"
            board["0,$i"]="k" ;;
        esac
        board["6,$i"]="P"
        board["1,$i"]="p"
    done
    save_board
}

print_pgn_header() {
    local pgn_file="$1"
    mapfile -t header_lines < <(awk '/^\[/{print} /^[[:space:]]*$/{exit}' "$pgn_file")
    if [ "${#header_lines[@]}" -eq 0 ]; then
        return
    fi

    echo "Metadata from PGN file:"

    local -a order=("Event" "Site" "Date" "Round" "White" "Black" "Result" "BlackElo" "ECO" "EventDate" "WhiteElo")
    declare -A printed=()
    for tag in "${order[@]}"; do
        for i in "${!header_lines[@]}"; do
            if [[ "${header_lines[$i]}" == "[$tag "* ]]; then
                echo "${header_lines[$i]}"
                printed[$i]=1
                break
            fi
        done
    done

    #print remaining header lines in original order
    for i in "${!header_lines[@]}"; do
        if [ -z "${printed[$i]}" ]; then
            echo "${header_lines[$i]}"
        fi
    done
}

#print current board
print_board() {
     echo ""
     echo "Move $current_move/$total"
    echo "  a b c d e f g h"
    for ((row=0; row<8; row++)); do
        echo -n "$((8-row)) "
        for ((col=0; col<8; col++)); do
            echo -n "${board["$row,$col"]} "
        done
        echo "$((8-row))"
    done
    echo "  a b c d e f g h"
}

#go one step forward - when we press "d"
d_function() {
    move=$1
    local row1=$((8 - ${move:1:1}))
    local row2=$((8 - ${move:3:1}))
    local col1=$(( $(printf "%d" "'${move:0:1}") - 97 ))
    local col2=$(( $(printf "%d" "'${move:2:1}") - 97 ))
    local last=${move:4:1}
    # Pawn Promotion
    if [ -n "$last" ]; then
        if [[ ${board["$row1,$col1"]} =~ [A-Z] ]]; then
            last=$(printf "%s" "${last^^}")
        fi
        board["$row1,$col1"]=$last
    #capture
    elif [[ ("${board[$row1,$col1]}" == "P" || "${board[$row1,$col1]}" == "p") && "${board[$row2,$col2]}" == "." &&
         "$col1" -ne "$col2" ]]; then
        board["$row1,$col2"]="."
    #kingside
    elif [[ ("${board[$row1,$col1]}" == "K" || "${board[$row1,$col1]}" == "k") && $((col2 - col1)) -eq 2 ]]; then
        board["$row1,5"]="${board["$row1,7"]}"
        board["$row1,7"]="."
    #queenside
    elif [[ ("${board[$row1,$col1]}" == "K" || "${board[$row1,$col1]}" == "k") && $((col1 - col2)) -eq 2 ]]; then
        board["$row1,3"]="${board["$row1,0"]}"
        board["$row1,0"]="."

    fi

    board["$row2,$col2"]=${board["$row1,$col1"]}
    board["$row1,$col1"]="."

    ((current_move++))
    if [ "$save_counter" -lt "$current_move" ]; then
        save_board
    fi
}

#go one move back, when we press "a"
a_function() {
    for ((i=0;i<8;i++)); do
        for ((j=0;j<8;j++)); do
            board["$i,$j"]="${saved_boards[$current_move,$i,$j]}"
        done
    done
    print_board
}


#save current board 
save_board() {
    for ((i=0;i<8;i++)); do
        for ((j=0;j<8;j++)); do
            saved_boards["$current_move,$i,$j"]="${board[$i,$j]}"
        done
    done
    ((save_counter++))
}
if test "$#" -ne 1
then 
    echo "Usage: $0 <pgn_file>"
    exit 1
fi

input_file="$1"
if test ! -f "$input_file"
then
    echo "Error: File '$input_file' does not exist."
    exit 1
fi
declare -A board
declare -A saved_boards

#read metadat
#initialize board 
#load moves
print_pgn_header "$input_file"
initialize_board
save_counter=0
current_move=0
moves=($(python3.8 parse_moves.py "$(cat "$input_file")"))
total=${#moves[@]}
print_board

#game loop
while true
do
    echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read char
    char=$(echo "$char" | tr -d '[:space:]')

    #move forward once
    if [ "$char" == "d" ]; then
        if [ "$current_move" -ne "$total" ]; then
            d_function "${moves[$current_move]}"
            print_board
        else
            echo ""
            echo "No more moves available."
        fi

    #move backward once
    elif [ "$char" == "a" ]; then
        if [ "$current_move" -gt 0 ]; then
            ((current_move--))
        fi
        a_function

    #go to beginning of game
    elif [ "$char" == "w" ]; then
        current_move=0
        a_function
    
    #go to end of game
    elif [ "$char" == "s" ]; then
        while [ "$current_move" -lt "$total" ]
        do
            d_function "${moves[$current_move]}"
        done
        print_board

    #quit game
    elif [ "$char" == "q" ]; then
         echo ""
         echo "Exiting."
         echo "End of game."
         exit 0

    #if input is invalid
    else
         echo ""
         echo "Invalid key pressed: $char"
    
    fi
done
