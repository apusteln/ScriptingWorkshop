#!/bin/bash

GRID=("T" "I" "C" "T" "A" "K" "T" "O" "E")
STRING=""
TEMP_ROW=""
TEMP_COL=""
MULTIPLAYER=0
ROLL=0
WINNER=""
CURRENT_PLAYER="X"
MY_FILE_DIR=$(dirname "$(readlink -f "$0")")

function draw_grid {
    clear
    echo
    echo "     -------"

    for X in {0..2}
    do
        STRING="|"

        for Y in {0..2}
        do
            STRING=${STRING}${GRID[3*X+Y]}\|
        done

        echo "     ${STRING}"
        echo "     -------"
    done
}

function update_grid {
    local row=$1
    local col=$2
    local char=$3
    idx=$(( 3 * $row + $col ))
    GRID[${idx}]=$char
}

function check_if_empty {
    local row=$1
    local col=$2
    idx=$(( 3 * $row + $col ))
    if [[ ${GRID[3*row+col]} == " " ]]
    then
        echo 1
    else
        echo 0
    fi
}

function is_grid_full {
    for X in {0..8}
    do
        if [[ ${GRID[X]} == " " ]]
        then
            echo 0
            return
        fi
    done
    echo 1
}

function ask_for_input {
    TEMP_ROW=" "
    TEMP_COL=" "
    local row=" "
    local col=" "

    echo "Please enter row and column numbers (numbers 1-3 separated by space)"
    echo "If you wish to exit the game please input \"E\""
    while [[ "$TEMP_ROW" == " " || "$TEMP_COL" == " " ]]
    do
        read -ra INPUT
        if [[ ${INPUT[0]} =~ ^[Ee].* ]]
        then
            echo "Would you like to save the state of the game?"
            read -ra INPUT
            if [[ ${INPUT[0]} =~ ^[Yy].* ]]
            then
                echo "The state will be saved in file: TicTacToe.sh_bak"
                save_state
            fi
            echo "Goodbye!"
            exit 0
        fi

        if [ ${#INPUT[@]} -lt 2 ]
        then
            echo "Too few inputs, please give at least two!"
            continue
        fi

        if ! [[ ${#INPUT[0]} -eq 1 && ${#INPUT[1]} -eq 1 && ${INPUT[0]} =~ [1-3] && ${INPUT[1]} =~ [1-3] ]]
        then
            echo "First two inputs not valid, please repeat!"
            continue
        fi

        row=$(expr ${INPUT[0]} - 1)
        col=$(expr ${INPUT[1]} - 1)

        if [[ $(check_if_empty ${row} ${col}) -eq 0 ]]
        then
            echo "Position is not empty, chose another position!"
            continue
        fi

        TEMP_ROW=$row
        TEMP_COL=$col
    done
}

function roll_computer_move {
    ROLL=$(expr 1 + $RANDOM % 9)
    while [[ ${GRID[$ROLL]} != " " ]]
    do
        ROLL=$(expr $RANDOM % 9)
    done
    TEMP_ROW=$(expr $ROLL / 3)
    TEMP_COL=$(expr $ROLL % 3)
}

function has_player_won {
    local player=$1

    for i in {0..2}
    do
        # Columns
        if [[ ${GRID[0+$i]} = "$player" &&  ${GRID[3+$i]} = "$player" && ${GRID[6+$i]} = "$player" ]]
        then
            echo 1
            return
        fi
        # Rows
        if [[ ${GRID[3*$i]} = "$player" &&  ${GRID[3*$i+1]} = "$player" && ${GRID[3*$i+2]} = "$player" ]]
        then
            echo 1
            return
        fi
    done
    # Diagonals
    if [[ ${GRID[0]} = "$player" &&  ${GRID[4]} = "$player" && ${GRID[8]} = "$player" ]]
    then
        echo 1
        return
    fi
    if [[ ${GRID[2]} = "$player" &&  ${GRID[4]} = "$player" && ${GRID[6]} = "$player" ]]
    then
        echo 1
        return
    fi
    echo 0
}

function has_game_ended {
    if [[ $(has_player_won X) -eq 1 ]]
    then
        echo X
        return
    else
        if [[ $(has_player_won O) -eq 1 ]]
        then
            if [[ $MULTIPLAYER -eq 1 ]]
            then
                echo O
            else
                echo C
            fi
            return
        fi
    fi

    if [[ $(is_grid_full) -eq 1 ]]
    then
        echo D
        return
    fi

    echo N
}

function save_state {
    local letter=""

    rm -r $MY_FILE_DIR/TicTacToe.sh_bak

    for i in {0..8}
    do
        if ! [ ${GRID[$i]} ]
        then
            letter="SPACE"
        else
            letter=${GRID[$i]}
        fi
        echo $letter >> $MY_FILE_DIR/TicTacToe.sh_bak
    done
    #printf "%s\n" "${GRID[@]}" > $MY_FILE_DIR/TicTacToe.sh_bak
    echo declare -p $MULTIPLAYER$CURRENT_PLAYER | cut -d ' ' -f 3- >> $MY_FILE_DIR/TicTacToe.sh_bak
}

function read_state {
    local idx=0

    while read -r line
    do
        if [ $line == "SPACE" ]
        then
            line=" "
        fi
        GRID[${idx}]=$line
        if [ $idx -gt 8 ]
        then
            MULTIPLAYER=${line:0:1}
            CURRENT_PLAYER=${line:1:1}
            break
        fi
        idx=$(expr $idx + 1)
    done < "$MY_FILE_DIR/TicTacToe.sh_bak"
}

function player_x_play {
    echo "Player X's turn" >&1
    ask_for_input
    update_grid $TEMP_ROW $TEMP_COL "X"
}

function player_o_play {
    if [[ $MULTIPLAYER -eq 1 ]]
    then
        echo "Player O's turn" >&1
        ask_for_input
        update_grid $TEMP_ROW $TEMP_COL "O"

    else
        roll_computer_move
        update_grid $TEMP_ROW $TEMP_COL "O"
    fi
}

function initial_setup {
    echo "X always goes first" >&1
    echo "Do you have another player to play with you? [y/n]: " >&1
    read INPUT

    while ! [[ $INPUT =~ ^[Yy].*|^[Nn].* ]]
    do
        echo "Sorry, I didn't understand that" >&1
        read INPUT
    done

    if [[ $INPUT =~ ^[Yy].* ]]
    then
        MULTIPLAYER=1
        if [[ "${#INPUT}" -gt 3 ]]
        then
            echo "I'll interpret this as \"Yes\"" >&1
        fi
        echo "Player two will play as \"O\"" >&1
        sleep 1
    else
        MULTIPLAYER=0
        if [[ "${#INPUT}" -gt 3 ]]
        then
            echo "I'll interpret this as \"No\"" >&1
            sleep 1
        fi
    fi
}


#Game starts here
draw_grid
sleep 1
GRID=(" " " " " " " " " " " " " " " " " ")
draw_grid

echo

if test -f "$MY_FILE_DIR/TicTacToe.sh_bak"
then
    echo "A game file has been discovered. Do you wish to start game from a saved file? [y/n]: "
    read -ra INPUT
    if [[ ${INPUT[0]} =~ ^[Yy].* ]]
    then
        echo "Reading game state"
        read_state
        if [ $CURRENT_PLAYER == "O" ]
        then
            draw_grid
            player_o_play
        fi
    else
        initial_setup
    fi
else
    initial_setup
fi

draw_grid
sleep 1

while true
do
    CURRENT_PLAYER="X"
    player_x_play

    draw_grid
    sleep 1

    if [[ $(has_game_ended) != "N" ]]
    then
        break
    fi

    CURRENT_PLAYER="O"
    player_o_play

    draw_grid
    sleep 1

    if [[ $(has_game_ended) != "N" ]]
    then
        break
    fi

done

WINNER=$(has_game_ended)

case $WINNER in
    D)
        echo "It's a draw!"
        ;;
    X)
        echo "Player X has won!"
        ;;
    O)
        echo "Player O has won!"
        ;;
    C)
        echo "You lost :("
        ;;
    *)
        echo "Something unexpected happened!"
        exit 1
        ;;
esac

if test -f "$MY_FILE_DIR/TicTacToe.sh_bak"
then
    echo "Removing the save file"
    rm $MY_FILE_DIR/TicTacToe.sh_bak
fi

exit 0
