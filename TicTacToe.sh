#1/bin/bash

GRID=("T" "I" "C" "T" "A" "K" "T" "O" "E")

STRING=""

PLAYER_ROW=""
PLAYER_COL=""
PLAYER2_ROW=""
PLAYER2_COL=""
COMPUTER_ROW=""
COMPUTER_COL=""
ROLL=0

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
	local char=$3
	idx=$(( 3 * $row + $col ))
	if [ "$GRID[${idx}]" = " " ]
	then
		return 1
	else
		return 0
	fi
}

function ask_for_input {
	echo "Please enter row and column numbers: "
	read -ra INPUT
	while [ ${#INPUT[@]} -lt 2 ]
	do
		echo "Too few inputs, please give at least two:"
		read -ra INPUT
	done
	
	if ! [[ "$INPUT[0]" =~ ^[0-2] && "$INPUT[1]" =~ ^[0-2] ]]
	then
		echo "First two inputs not valid, I'm not playing like this :("
		exit 1
	fi
	
	PLAYER_ROW=${INPUT[0]}
	PLAYER_COL=${INPUT[1]}
}

function roll_computer_move {
	ROLL=$(expr 1 + $RANDOM % 9)
	while [ "${GRID[${ROLL}]}" != " " ]
	do
		ROLL=$(expr $RANDOM % 9)
	done
	
	COMPUTER_ROW=$(expr $ROLL / 3)
	COMPUTER_COL=$(expr $ROLL % 3)
}

function has_player_won {
	local player=$1
	
	for i in {0..2}
	do
		# Rows
		if [[ ${GRID[0+$i]} = "$player" &&  ${GRID[3+$i]} = "$player" && ${GRID[6+$i]} = "$player" ]]
		then
			echo akaka
			return
		fi
		# Columns
		if [[ ${GRID[3*$i]} = "$player" &&  ${GRID[3*$i+1]} = "$player" && ${GRID[3*$i+2]} = "$player" ]]
		then
			echo akaka
			return
		fi
	done
	# Diagonals
	if [[ ${GRID[0]} = "$player" &&  ${GRID[4]} = "$player" && ${GRID[8]} = "$player" ]]
	then
		echo akaka
		return
	fi
	if [[ ${GRID[2]} = "$player" &&  ${GRID[4]} = "$player" && ${GRID[6]} = "$player" ]]
	then
		echo akaka
		return
	fi
	echo ukuku
}



draw_grid
sleep 1
GRID=("X" "Y" "Z" " " " " " " " " " " " ")
draw_grid





echo ABCD

abc=$(has_player_won X)

echo $abc

ccc=$(expr 1 + 3)

echo $ccc


# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
# roll_computer_move
# update_grid $COMPUTER_ROW $COMPUTER_COL "O"
# draw_grid
# echo
