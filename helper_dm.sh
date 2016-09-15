#!/bin/bash

#Directory for images
INPUT_DIR=${2%.*}
#Directory for output
OUTPUT_DIR=$INPUT_DIR"_out"
#Directory for score
SCORE_DIR="score"
OUT="-out"
V="-v"
FLAG_O="0"
FLAG_V="0"

if [ -f "$1" ]; then
    #Create input dir and remove old if necessary
    if [ -d "$INPUT_DIR" ]; then
        echo "Directory '$INPUT_DIR' exists already. Press y/Y to delete or else to exit ..."
        read RESP
        if [ "$RESP" == "y" ] || [ "$RESP" == "Y" ]; then
            rm -rf $INPUT_DIR
        else
            exit 1
        fi
    fi
    mkdir $INPUT_DIR
    if [ -f "$2" ]; then
        ffmpeg -i $2 $INPUT_DIR/$filename%06d.jpg
        echo " "
        echo "Frame extraction done."
    else
        echo "'$2' not valid. Please check."
        exit 1
    fi

    OPTIONS=""
    for VAR in ${@:3}; do
        #For parsing -out option
        #order is CRITICAL
        if [ "$VAR" == "$OUT" ]; then
            FLAG_O=1
            continue
        fi
        if [ $FLAG_O -eq 1 ]; then
            FLAG_O=2
            OUTPUT_DIR=$VAR
            continue
        fi
        if [ "$VAR" == "$V" ]; then
            FLAG_V=1
        fi
        OPTIONS=$OPTIONS" "$VAR
    done
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir $OUTPUT_DIR
    fi
    if [ $FLAG_V -eq 0 ]; then
        OPTIONS=$OPTIONS" "$V
    fi

    #Creating folders for score output
    COUNTER=1
    SCORE_DIR="$OUTPUT_DIR""/""$SCORE_DIR"
    if [ -d "$SCORE_DIR" ]; then
        echo " "
        echo "'""$SCORE_DIR""' already exists. Press y/Y to delete or else to exit ..."
        read RESP
        if [ "$RESP" == "y" ] || [ "$RESP" == "Y" ]; then
            rm -rf $SCORE_DIR
        else
            exit 1
        fi
    fi
    mkdir $SCORE_DIR
    while [ $COUNTER -ne 11 ]; do
        MIN=`bc <<< 'scale=2;('$COUNTER'-'1')*'10`
        MAX=`bc <<< 'scale=2;'$COUNTER'*'10'-'1`
        mkdir "$SCORE_DIR""/""$MIN""_""$MAX"
        COUNTER=`expr $COUNTER + 1`
    done
    mkdir "$SCORE_DIR""/100"

    if [ -f $OUTPUT_DIR/result_score.txt ]; then
        echo " "
        echo "'$OUTPUT_DIR/result_score.txt' already exists."
        echo "Renaming it to '$OUTPUT_DIR/result_score_old.txt' file."
        mv -f $OUTPUT_DIR/result_score.txt $OUTPUT_DIR/result_score_old.txt
    fi
    echo " "

    #Iterating over each file in folder
    #and appling DeepMatching to it.
    I="1"
    echo " "
    for ENTRY in $INPUT_DIR/*
    do
        echo "Matching image $I ..."
        ./deepmatching-static $1 $ENTRY $OPTIONS -out $OUTPUT_DIR/$I".txt" > temp_verbose.txt

        if [ $FLAG_V -eq 1 ]; then
            cat temp_verbose.txt
        fi

        #Reading verbose file
        J="0"
        while read line; do
            J=`expr $J + 1`
            if [ $J -eq 2 ]; then
                break
            fi
        done < temp_verbose.txt

        #Calculating scores and writing to file
        L=( $line )
        MAX_MATCHES=${L[1]}
        NUM_LINES=`wc -l < $OUTPUT_DIR/$I".txt"`
        if [ $FLAG_O -eq 0 ]; then
            rm -f $OUTPUT_DIR/$I".txt"
        fi
        SCORE=`bc <<< 'scale=2;'$NUM_LINES'/'$MAX_MATCHES`
        echo $ENTRY" "$SCORE >> $OUTPUT_DIR/result_score.txt

        #Coping image files to respective folders
        INDEX=`bc <<< '('$SCORE'*'100')/'10`
        INDEX=`expr $INDEX + 1`
        MIN=`bc <<< 'scale=2;('$INDEX'-'1')*'10`
        MAX=`bc <<< 'scale=2;'$INDEX'*'10'-'1`
        cp -f $ENTRY "$SCORE_DIR""/""$MIN""_""$MAX"
        FILE_NAME=$(basename $ENTRY)
        echo "$SCORE_DIR""/""$MIN""_""$MAX""/""$FILE_NAME"" "$SCORE >> "$SCORE_DIR""/""$MIN""_""$MAX""/"result_score.txt
        I=`expr $I + 1`
    done
    rm -f temp_verbose.txt
else
    echo "'$1' not valid. Please check."
fi
