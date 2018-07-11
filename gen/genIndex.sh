#! /bin/bash

HERE=$(PWD)

cd "$HERE"
cd convoar
BASENAMES=$(ls -d * | grep -v json)

# Header
cat <<EOFFF
EOFFF
echo -e "{"

ADDCOMMAB=false
for BASENAME in $BASENAMES ; do
    cd "$HERE/convoar/${BASENAME}"

    # if special file "HIDDEN" exists, don't put entry into the output JSON file
    if [[ ! -e "HIDDEN" ]] ; then

        if [[ $ADDCOMMAB == true ]] ; then
            echo -e ","
        fi
        echo -e "\"${BASENAME}\": {"

        ADDCOMMA=false
        if [[ -e "${BASENAME}.oar" ]] ; then
            if [[ $ADDCOMMA == true ]] ; then
                echo -e "\t,"
            fi
            echo -e "\t\"oar\": \"${BASENAME}.oar\""
            ADDCOMMA=true
        fi

        if [[ -e "${BASENAME}.jpg" ]] ; then
            if [[ $ADDCOMMA == true ]] ; then
                echo -e "\t,"
            fi
            echo -e "\t\"image\": \"${BASENAME}.jpg\""
            ADDCOMMA=true
        fi

        if [[ -e "${BASENAME}.txt" ]] ; then
            if [[ $ADDCOMMA == true ]] ; then
                echo -e "\t,"
            fi
            echo -e "\t\"desc\": \"" $(cat ${BASENAME}.txt) "\""
            ADDCOMMA=true
        fi

        if [[ -e "${BASENAME}.html" ]] ; then
            if [[ $ADDCOMMA == true ]] ; then
                echo -e "\t,"
            fi
            echo -e "\t\"desc\": \"${BASENAME}.html\""
            ADDCOMMA=true
        fi

        TYPES=$(ls -d * | grep -v "\.")

        if [[ $ADDCOMMA == true ]] ; then
            echo -e "\t,"
        fi
        echo -e "\t\"types\": {"
        ADDCOMMA2=false
        for TYPE in $TYPES ; do
            if [[ $ADDCOMMA2 == true ]] ; then
                echo -e "\t\t,"
            fi
            ADDCOMMA3=false
            echo -e "\t\t\"$TYPE\": {"
            if [[ -e "${TYPE}/${BASENAME}.gltf" ]] ; then
                if [[ $ADDCOMMA3 == true ]] ; then
                    echo -e "\t\t,"
                fi
                echo -e "\t\t\t\"gltf\": \"${BASENAME}.gltf\""
                ADDCOMMA3=true
            fi

            if [[ -e "${TYPE}/${BASENAME}.zip" ]] ; then
                if [[ $ADDCOMMA3 == true ]] ; then
                    echo -e "\t\t,"
                fi
                echo -e "\t\t\t\"zip\": \"${BASENAME}.zip\""
                ADDCOMMA3=true
            fi

            if [[ -e "${TYPE}/${BASENAME}.tgz" ]] ; then
                if [[ $ADDCOMMA3 == true ]] ; then
                    echo -e "\t\t,"
                fi
                echo -e "\t\t\t\"tgz\": \"${BASENAME}.tgz\""
                ADDCOMMA3=true
            fi

            echo -e "\t\t\t}"
            ADDCOMMA2=true
        done
        echo -e "\t\t}"

        echo -e "\t}"
        ADDCOMMAB=true
    fi

done

echo -e "}"
