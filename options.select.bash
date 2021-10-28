#!/usr/bin/bash
# Title			: Options Select Bash Script
# Summary		: A function that helps user to make a choice
# Created-at	: Friday, October 22, 2021 
# Last-Modified : Thursday, October 28, 2021s
# Repository	: N/A
# Authors		: Alex A. Davronov <al.neodim@gmail.com> (2021-)
# Description	: See README
# Usage			: Use it either from /usr/bin path or source it as a script
# Hit [ctrl+c] to abort.
# $ ./options.select.bash foo bar baz # 
# $ ./options.select.bash foo bar baz # selected one
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
## @summary Get a cursor position int $ROW and $COL variables
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
    key="";

    [[ `shell.name` == 'bash'  ]] && read -s -n3 key 2>/dev/null >&2;
    [[ `shell.name` == 'zsh'   ]] &&\
    {
        read -s -k1 k0 2>/dev/null >&2;
        [[ $k0 = $'\n'    ]] && echo enter && return 0;
        read -s -k2 k1 2>/dev/null >&2;
        key=$k0$k1
    }

    # [[ ${key[1]} = $'\n'   ]] && echo enter;
    [[ $key      = $'\e[A' ]] && echo up;
    [[ $key      = $'\e[B' ]] && echo down; 
    [[ $key      = $'\eq'  ]] && echo ctrlq;
    [[ $key      = ""      ]] && echo enter;

}

# Anonymous encapsulation
# ------------------------------------------------------------____options.select
____options.select()
{

    options.select.version(){ echo 1.0.1; }

    # @summary Print option
    # @param $value - Value to print
    option.print() { printf "   $1 "; }

    # @summary Print sELECTED option (colored)
    # @param $value - Value to print
    option.selected.print() { printf "  >\e[7m$1\e[27m"; }

    #-------------------------------------------------------------options.select
    # @summary Print interactive selection menu.
    # @description Selection is done by using [Up]/[Down] arrows and [Enter] key
    # The result of selection can by read by using 
    # @param $options - Name (string) reference to an array e.g. "myFooArr"
    # @param $prompt  - Prompt to print at the bottom. Default to TIP: Please...
    # @param $width   - Prompt to print at the bottom. Default to 3
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
        
        # Entries output configuration
        #-------------------------------------
        local prompt=${2:-"\e[7mTIP: Please use arrows (up/down) to make a choice. Current index is %index/%total\e[0m"}

                
        # Misc
        #-------------------------------------
        # Current screen position for overwriting the options__
              shell.cursor.pos.at;
        local shell_row_initial=$ROW;
        local shell_row_current=$(($shell_row_initial));
        # If aborted, return back to home screen
        local TRAP_LISTENER="tput cnorm; tput home; stty echo; clear; echo 'Aborted!'; return 0;";
        trap "$TRAP_LISTENER" 1;
        trap "$TRAP_LISTENER" 2;

        # shell.blink.disable
        tput civis # hide cursor
        local idx=1;
        while true; do
            # Print options__ by overwriting the last lines
            #-------------------------------------
            tput clear;
            printf "\n";
        
        local idx_prev=$((idx-1));
        local idx_next=$((idx+1));
        local options___current=${options__[$idx]};
            
            tput cup $(($shell_row_current + 1)) 1;
            [[ $idx_prev -lt 1 ]] && idx_prev=$options___length;
            option.print "${options__[$idx_prev]}";
            
            tput cup $(($shell_row_current + 2)) 1;
            option.selected.print "$options___current";
            
            tput cup $(($shell_row_current + 3)) 1;
            [[ $idx_next -gt $options___length ]] && idx_next=1;
            option.print "${options__[$idx_next]}";
            
            
            # Render prompt. Replace %index/%total and other vars
            #-------------------------------------
            tput cup $(($shell_row_current + 5)) 1;
            _prompt="${prompt/\%index/$idx}";
            _prompt="${_prompt/\%total/$options___length}";
            _prompt="${_prompt/\%selected/$options___current}";
            _prompt="${_prompt/\%kbd/$kbd}";
            option.print "$_prompt"

            kbd=$(shell.input.read)
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
                ctrlq)
                        break;
                ;;
            esac
        done

        tput cup $shell_row_initial 1;
        tput cnorm;
        tput clear;
        return $idx
    }

    # ----------------------------------------------------------------cli
    # @summary Main CLI handler
    cli()
    {
        local COMMAND1=$1;
        case $COMMAND1 in
            (-v|--version) options.select.version;;
            (print)
                shift;
                local arr=("$@");
                # prints content of the array
                # declare -p arr;
                options.select arr;
                echo $SELECTED
            ;;
            (*)
                options.select "$@";
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
    ____options.select print "$@"
fi

# The disgrace begins when a man writes not well, but badly.- Socrates, Phaedrus