#!/usr/bin/bash
# Title			: Options Select Bash Script
# Summary		: A function that helps user to make a choice
# Created-at	: October 22, 2021 
# Repository	: N/A
# Authors		: Alex A. Davronov <al.neodim@gmail.com> (2021-)
# Description	: See README
# Usage			: Use it either from /usr/bin path or source it as a script
# Hit [ctrl+c] to abort.
# $ ./options.select.bash foo bar baz # selected one
# $ source ./options.select.bash # source to use as separate command
# $ options.select optionsArray "Footer text"
# Options Select Bash Script
# Copyright (C) 2021- Alex A. Davronov <al.neodim@gmail.com>
# 
# Redistribution and (re)use of this Source or Binary code produced from such
# regardless of the carrier with or without modification is permitted free of
# charge (unless explicitly stated otherwise herewith) provided that
# the following conditions are met:
# 
#    1.	Redistributions of the Source code must retain the above
#        Copyright notice, this List of conditions, and the following
#        Disclaimer.
# 
#    2.	Redistributions of the Binary code must reproduce the above
#        Copyright notice, this List of conditions, and the following
#        Disclaimer visible prominently and clearly to the user's eyes
#        within documentation provided with such distribution or at the
#        user request immediately.
# 
#    3.	Failure to meet the List of condition set hereby terminates
#        unconditionally your rights and permissions granted by the above
#        Copyright notice and makes you eligible for prosecution, lawsuit or any
#        legal actions or proceedings under appropritate law of a country of your
#        or licensor's residence or International law if applicable.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# --------------------------------------------------------------------shell.name
# @summary I detect which kind shell (zsh, bashh etc..) the script is run in.
# @usage $ declare currentShell="$(shell.name)";
# @param $shellName - A reference name for an output
type shell.name &> /dev/null || shell.name(){
type compdef    &> /dev/null && { echo "zsh" ;  return 0; };
type complete   &> /dev/null && { echo "bash" ; return 0; };
}

#------------------------------------------------------------shell.cursor.pos.at
# @summary Get a cursor position int $ROW and $COL variables
# @usage
# $ shell.cursor.pos.at
# $ echo ROW COL
shell.cursor.pos.at()
{
			echo -en '\e[6n';
			read -s -d '[';
	IFS=';' read -s -d 'R' ROW COL;
}


#---------------------------------------------------------------shell.input.read
# @summary A crossplatform function to read enter|up|down keypresses from stdin
# @description Use it in a while loop to extract currently pressed key
# @usage $ echo $(shell.input.read) # => enter|up|down
# @return - Integer
type shell.input.read    &> /dev/null || shell.input.read()
{
	local SILENT_FLAG=${1:-'-s'};
	key="";
	[[ `shell.name` == 'bash'  ]] && read $SILENT_FLAG -n3 key 2>/dev/null >&2;
	[[ `shell.name` == 'zsh'   ]] &&\
	{
		read $SILENT_FLAG -k1 k0 2>/dev/null >&2;
		# NASTY BUG! Dor't forget to keep the `[[` from next char
		[[ "$k0" = $'\n'    ]] && echo enter && return 0;
		read $SILENT_FLAG -k2 k1 2>/dev/null >&2;
		key=$k0$k1
	}
	# [[ ${key[1]} = $'\n'   ]] && echo enter;
	[[ $key      = $'\e[A' ]] && echo up;
	[[ $key      = $'\e[B' ]] && echo down; 
	[[ $key      = ""      ]] && echo enter;
}


# Anonymous encapsulation
# ------------------------------------------------------------____options.select
____options.select.version(){ echo 2.0.0; }
____options.select.updated(){ echo October 29, 2021; }
____options.select()
{

	# @summary Print option
	# @param $value - Value to print
	option.print() { echo -e " $1                                "; }

	# @summary Print sELECTED option (colored)
	# @param $value - Value to print
	option.selected.print() { echo -e ">\e[7m$1\e[27m                                "; }

	#-------------------------------------------------------------options.select
	# @summary Print interactive selection menu.
	# @description Selection is done by using [Up]/[Down] arrows and [Enter] key
	# The result of selection can by read by using 
	# @param $options - Name (string) reference to an array e.g. "myFooArr"
	# @param $footer  - Footer to print at the bottom. Default to TIP: Please...
	# @param $width   - Footer to print at the bottom. Default to 3
	options.select(){

		# Output variables; global
		#-------------------------------------
		declare -g SELECTED=""    
		declare -g SELECTED_IDX=""

		# options
		#-------------------------------------
		[[ `shell.name` == 'bash'  ]] &&\
		{
			local -n options__=${1:?"options__ array name should be provided!"};
					 options__=('' "${options__[@]}");
			local    options___length=$((${#options__[@]} - 1));

		}
		[[ `shell.name` == 'zsh'   ]] &&\
		{
			local options__=${1:?"options__ array name should be provided!"};
				  options__=(${(P)options__});
			local options___length=$((${#options__[@]}));
		}
		
		[[ ${#options__[@]} -lt 2 ]] \
		&& {
			echo -e "\e[38;2;255;32;32mERROR: There must be at least 2 options!\e[0m";
			return 1;
		}
		
		# Header & footer
		#-------------------------------------
		local footer=${2:-"\e[7mTIP: Please use arrows (up/down) to make a choice. Current index is %index/%total\e[0m"}
		local header=${3};
		local _footer;
		local _header;

		# Misc
		#-------------------------------------
		# Current screen position for overwriting the options__
			  shell.cursor.pos.at;
		local shell_row_initial=$ROW;
		local shell_row_current=$(($shell_row_initial));
		
		
		# # If aborted, return back to home screen
		#-------------------------------------
		local TRAP_LISTENER="tput cnorm; tput home; stty echo; clear; echo 'Aborted!'; return -1;";
		trap "$TRAP_LISTENER" 1;
		trap "$TRAP_LISTENER" 2;

		# Cap maxium number of lines displayed (2.0.0)
		#-------------------------------------
		local render_entries_max=$(($options___length));
		[[ $options___length -gt 7  ]] && render_entries_max=7;
		[[ $options___length -gt 15 ]] && render_entries_max=15;
		[[ $options___length -gt 31 ]] && render_entries_max=31;
		# [[ $options___length -gt $(tput lines) ]] && render_entries_max=63;

		local -i i render_entries_len=$((render_entries_max));
		local -i idx=${INDEX_PRESET:-1};
		tput civis; # hide cursor
		while true; do
			
			tput clear;
			# Move to a row column
			tput cup $(($shell_row_initial)) 1;
			
			# Render header. Replace %index/%total and other vars
			#-------------------------------------
			if [[ "$header" ]];
			then
				# printf 'idx=% 3s |  render_entries_len=% 3s | max=% 3s'  $idx $i_relative_idx $render_entries_len $render_entries_max;

				shell_row_current=$((shell_row_initial + 1));
				tput cup $(($shell_row_current)) 1;
				_header="${header/\%index/$idx}";
				_header="${_header/\%total/$options___length}";
				option.print "$_header"
			fi
			# Render vieport lines.
			# Viewport is a list of entries which are visible
			# Viewport is offset relatively to user-controlled $idx index
			#-------------------------------------
			for ((i=1; i <= render_entries_len; i++));
			do
				tput cup $(($shell_row_current + i)) 1;
				local i_relative_idx=$i;
				[[ $idx -ge $render_entries_len ]] && i_relative_idx=$((i+idx-render_entries_len));# offset
				local value=${options__[$i_relative_idx]}; 

				# If idx is pointing at the curren render line of the viewport
				if [[ $i -eq  1 ]] && [[ $i_relative_idx -eq 1 ]] && [[ $idx -eq 1 ]];
				then
					option.selected.print "$value";
					continue;
				fi

				if [[ $i -eq $render_entries_max ]] && [[ $i_relative_idx -gt $render_entries_max  ]];
				then
					option.selected.print "$value";
					continue;
				fi

				if [[ $idx -eq  $i ]];
				then
					option.selected.print "$value";
				else
					option.print "$value"
				fi

			done # for loop

			# Render footer. Replace %index/%total and other vars
			#-------------------------------------
			tput cup $(($shell_row_current + render_entries_len + 2)) 1;
			_footer="${footer/\%index/$idx}";
			_footer="${_footer/\%total/$options___length}";
			_footer="${_footer/\%selected/$options___current}";
			_footer="${_footer/\%kbd/$kbd}";
			option.print "$_footer"

			# BUG: ZSH input isn't read
			kbd=$(shell.input.read);
			# user key control
			case $kbd in
				enter)  export SELECTED=${options__[$idx]};
						export SELECTED_IDX=$idx;
						break
				;;
				up)     ((idx--));
						[[ $idx -lt 1 ]] && idx=$options___length;
				;;
				down)   ((idx++));
						[[ $idx -gt $options___length ]] && idx=1;
				;;
			esac
		done # while loop

		# Return cursor back to its position
		# before the scriptrun and reset its state
		# Clear screen
		tput cup $shell_row_initial 1;
		tput cnorm;
		tput clear;
		return $SELECTED_IDX
	}

	# -------------------------------------------------options.select.completion
	# @summary I'm tasked with setting up completion for Zsh/Bash
	# @usage  $ options.select.completion
	options.select.completion()
	{
		: echo #TODO: finish completion 
	
	} # options.select.completion end

	# ----------------------------------------------------------------cli
	# @summary Main CLI handler
	cli()
	{
		local COMMAND1=$1;
		case $COMMAND1 in
			(-v|--version) ____options.select.version ;;
			(-h|--help) 
				cat <<-EOL
				Commands:
				   from <items>
				   -v|--version
				   -h|--help

				Example
				   "\e[;38;2;255;127;0m"source $HOME/.local/bin/options.select.bash;
				   arrayName=(one two three);
				   options.select arrayName "Whoa! Index is %index/%total";\e[0m
				   

				Options Select Bash Script v$(____options.select.version) ($(____options.select.updated))
				See LICENSE file (or comment at the top of the files)
				provided along with the source code for additional info
				Copyright (C) 2021- Alex A. Davronov <al.neodim@gmail.com>
				Learn more about script here https://github.com/hinell/options-select-bash
				EOL
			;;
			# Since 2.0.0  
			(from)
				shift;
				local arr=("$@");
				# prints content of the array
				# declare -p arr;
				options.select arr;
				echo $SELECTED
			;;
			(*)
				options.select "$@"
			;;
		esac
		return $SELECTED_IDX;
	}

	cli "$@";
} # ____options.select end

# ----------------------------------------------------------main-function-export
if [[ ${BASH_SOURCE[0]} != $0 ]]; then
	# Alias the exported function, if necessary
	EXPORT_NAME="options.select"
	eval "$EXPORT_NAME(){ ____options.select \"\$@\";}" &> /dev/null
	case "$(shell.name)" in
		(zsh)
			# Exports for ZSH - FUCK ZSH
			eval "typeset -f $EXPORT_NAME" &> /dev/null
		;;
		(bash);& 
		(*)
			# Exports for Bash and the rest
			eval "export -f $EXPORT_NAME"
		;;
	esac
else
	____options.select "$@"
fi

# The disgrace begins when a man writes not well, but badly.- Socrates, Phaedrus