#!/bin/bash


# This sources main script
#-------------------------------------
. ./options.select.bash


# ANSI coloring
#-------------------------------------
text.rgb (){ printf 'This color is beautiful [%03i %03i %03i]' $1 $2 $3; };
text.fill(){
    local rgb="$1;$2;$3";
    shift 3;
    echo "\e[48;2;${rgb}m"$@" \e[0m";
};

# 
# ---------------------------------------------------------------------Example_1
# Prepare intput & output
Example_1()
{
    export SELECTED=();
    export options=();
    range=`echo {0..7}`;
    let i=0;
    for r in $range; do
        for g in $range; do
            for b in $range; do
                _r=$((r*32));
                _g=$((g*32));
                _b=$((b*32));
                text="$(text.rgb $_r $_g $_b)";
                
                options[$i]=$(text.fill $_r $_g $_b "$text");
                ((i++));
            done
        done
    done
    export prompt=\\e[30m`text.fill 255 200 0 "PLEASE, CHOOSE COLORS!^^^^^^^^^^^^[%index]"`;
    options.select options "$prompt"
    echo -e $SELECTED
}


# ---------------------------------------------------------------------Example_2
Example_2()
{
    opts=($(echo -e \\e[3{1..7}m{0..7}_OPTION\\e[0m ));
    options.select opts;
    echo -e "$SELECTED";
} # Example_2 end



# ----------------------------------------------------------------Example_3
Example_3()
{
    COLOR_TEMPLATES=($(echo -e "\\e[3"{1..7}"m"{0..7}"_OPT\\e[0m\\n"));
    LOREM="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.."
    declare template;
    declare -a opts=();
    declare -i i len=${#COLOR_TEMPLATES[@]};
    for ((i=1; i <= len - 1; i++));
    do
        declare template=${COLOR_TEMPLATES[$i]};
                template=${template/_OPT/$LOREM};
                opts[$i]="$template";
    done;
    options.select opts "Please, select choice! Current: [%index]/[%total] [%kbd]";
    echo -e "$SELECTED";
} # Example_3 end

examples=();
examples+=("Example_1: Colorful example.");
examples+=("Example_2: Concise one, checkout");
examples+=("Example_3: A bit more complicated.");
options.select examples "Which example to run?"
${SELECTED%%:*}