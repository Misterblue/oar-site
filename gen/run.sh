#! /bin/bash

HERE=$(pwd)

# whether to delete the target directory before trying to build
DOCLEAN=yes
# whether to build
DOBUILD=yes
# whether to generate the JSON index of the directories
GENINDEX=yes
# whether to copy the directories to the servers
DOCOPY=no

# if set to 'yes', will attempt to run the docker version of convoar
USEDOCKER=no

CONVOAR=$HERE/../../convoar/dist/convoar.exe
OARPLACE=../../oar-site-oars

# PROCESSING="UNOPTIMIZED"
# PROCESSING="SMALLASSETS"
# PROCESSING="MERGEDMATERIALS"
# PROCESSING="UNOPTIMIZED SMALLASSETS"
PROCESSING="UNOPTIMIZED SMALLASSETS MERGEDMATERIALS"

if [[ ( "$DOCOPY" == "yes" ) && ( -z "$MB_REMOTEACCT" || -z "$MB_REMOTEHOST" ) ]] ; then
    echo "Cannot run script without MB_REMOTEACCT and MB_REMOTEHOST environment variables set"
    exit
fi
REMOTEACCT=${MB_REMOTEACCT:-mb}
REMOTEHOST=${MB_REMOTEHOST:-someplace.misterblue.com}
REMOTEBASE=files.misterblue.com/BasilTest

DOVERBOSE=""
# DOVERBOSE="--Verbose"

OARS=""
# OARS="$OARS Olaf.oar"
# OARS="$OARS alfea3.oar"
# OARS="$OARS art_city_2025.oar"
# OARS="$OARS Atropia_00.oar"
# OARS="$OARS Atropia_01.oar"
# OARS="$OARS Atropia_02.oar"
# OARS="$OARS Atropia_10.oar"
# OARS="$OARS Atropia_11.oar"
# OARS="$OARS Atropia_12.oar"
# OARS="$OARS Atropia_20.oar"
# OARS="$OARS Atropia_21.oar"
# OARS="$OARS Atropia_22.oar"
# OARS="$OARS AuroraFreeFurniture.oar"
# OARS="$OARS boardwalk.oar"
# OARS="$OARS Desert.oar"
# OARS="$OARS epiccastle.oar"
# OARS="$OARS EpicCitadel.oar"
# OARS="$OARS Fantasy.oar"
# OARS="$OARS FirestormOrientation_Island.oar"
# OARS="$OARS GoneCity.oar"
# OARS="$OARS IMAOutpostAlphaForest.oar"
# OARS="$OARS IMAOutpostAlphaTerrain.oar"
# OARS="$OARS InstituteForSimulationTechnology.oar"
# OARS="$OARS IST_01-14.10.03.oar"
# OARS="$OARS large_structures_01.oar"
# OARS="$OARS LOBBY_1-2015-02-17.oar"
# OARS="$OARS OAR-2worlds_City_by_Andie_Linette.oar"
# OARS="$OARS OAR-Airport_1.4_by_Andie_Linette.oar"
# OARS="$OARS OAR-Basilica-CC-BY-CA.oar"
# OARS="$OARS OAR-haxor_outpost78_by_Ener_Hax.oar"
# OARS="$OARS OAR-Medieval_by_Avia_Bonne.oar"
# OARS="$OARS Olaf.oar"
# OARS="$OARS onikenkon_megapack_v1.0_20121006.oar"
# OARS="$OARS opensim-openvce.oar"
# OARS="$OARS OSGHUG-cyberlandia.oar"
# OARS="$OARS OSGHUG-Mars.oar"
# OARS="$OARS OSGHUG-maya3.oar"
# OARS="$OARS OSGHUG-reefs.oar"
# OARS="$OARS PalmyraTemple.oar"
# OARS="$OARS Region-3dworlds-20170604.oar"
# OARS="$OARS reticulation_2014-06-08.oar"
# OARS="$OARS sierpinski_triangle_122572_prims_01.oar"
# OARS="$OARS SingularityOrientation_Island.oar"
# OARS="$OARS testtest1.oar"
# OARS="$OARS testtest88.oar"
# OARS="$OARS universal_campus_01_0.7.3_03022012.oar"
# OARS="$OARS WinterLand.oar"
# OARS="$OARS ZadarooSwamp.oar"

cd "$HERE"
cd "$OARPLACE"
# This defines the list of OARs to build as the contents of the directory of OARs.
# Comment out this line to manually specify OAR names (the list above).
OARS=$(ls *.oar)
cd "$HERE"

for OAR in $OARS ; do
    BASENAME="$(basename -s .oar $OAR)"
    for PROCESS in $PROCESSING ; do
        if [[ "$PROCESS" == "UNOPTIMIZED" ]] ; then
            PARAMS="$DOVERBOSE --TextureMaxSize 4096 --HalfRezTerrain false"
            SUBDIR=unoptimized
        fi
        if [[ "$PROCESS" == "SMALLASSETS" ]] ; then
            PARAMS="$DOVERBOSE"
            SUBDIR=smallassets
        fi
        if [[ "$PROCESS" == "MERGEDMATERIALS" ]] ; then
            PARAMS="$DOVERBOSE --MergeSharedMaterialMeshes true"
            SUBDIR=mergedmaterials
        fi
        # PARAMS="$PARAMS --logGltfBuilding --verbose --LogBuilding --LogConversionStats"
        PARAMS="$PARAMS --OutputDir ."

        cd "$HERE"
        mkdir -p convoar/${BASENAME}

        # put a copy of the original OAR into the built tree
        cd "$HERE"
        if [[ ! -e "convoar/${BASENAME}/${OAR}" ]] ; then
            echo "======= copying $OAR to convoar/${BASENAME}"
            cp "$OARPLACE/$OAR" convoar/${BASENAME}
        fi

        # Add a JPG of the OAR file to the build tree if it exists
        if [[ -e "$OARPLACE/${BASENAME}.jpg" ]] ; then
            cp "$OARPLACE/${BASENAME}.jpg" "convoar/${BASENAME}"
        fi
        # Add a description of the OAR file to the build tree if it exists
        if [[ -e "$OARPLACE/${BASENAME}.txt" ]] ; then
            cp "$OARPLACE/${BASENAME}.txt" "convoar/${BASENAME}"
        fi
        # Add a description of the OAR file to the build tree if it exists
        if [[ -e "$OARPLACE/${BASENAME}.html" ]] ; then
            cp "$OARPLACE/${BASENAME}.html" "convoar/${BASENAME}"
        fi

        DIR="convoar/${BASENAME}/$SUBDIR"

        # Optionally clean out the directory for a clean build
        if [[ "$DOCLEAN" == "yes" ]] ; then
            echo "======= cleaning $DIR"
            cd "$HERE"
            rm -rf "$DIR"
            mkdir -p "$DIR"
        fi

        # If doing build and files have not already been built, do the build
        if [[ "$DOBUILD" == "yes" ]] ; then
            if [[ ! -e "${DIR}/${BASENAME}.gltf" ]] ; then
                echo "======= building $DIR"
                cd "$HERE"
                rm -rf "$DIR"
                mkdir -p "$DIR"
                cd "$DIR"
                if [[ "$USEDOCKER" == "yes" ]] ; then
                    cp "../$OAR" .
                    # run the docker app using the UID of the current user so they can access directory
                    echo "DOING: docker run --user $(id -u):$(id -g) --volume $(pwd):/oar ghcr.io/misterblue/convoar:latest \"$PARAMS\" \"$OAR\""
                    docker run --user $(id -u):$(id -g) --volume $(pwd):/oar herbal3d/convoar:latest "$PARAMS" "$OAR"
                    rm -f "$OAR"
                else
                    $CONVOAR  $PARAMS "../$OAR"
                fi
                # Create a gltf files that has the name of the OAR file
                cd "$HERE"
                cd "$DIR"
                cp *.gltf ${BASENAME}.gltf
                # Create a single TGZ file with all the content for the 3DWebWorldz people
                cd "$HERE"
                cd "$DIR"
                tar -czf "${BASENAME}.tgz" *
                # Create a single ZIP file with all the content for the 3DWebWorldz people
                cd "$HERE"
                cd "$DIR"
                zip -r -q ${BASENAME} *.gltf *.buf images
            else
                echo "======= not building $DIR: already exists"
            fi
        fi
    done
done

# Generate an indes for the directory
cd "$HERE"
if [[ "$GENINDEX" == "yes" ]] ; then
    ./genIndex.sh > convoar/index.json
fi

# Update the Internet repositories with new version of everything
cd "$HERE"
if [[ "$DOCOPY" == "yes" ]] ; then
    if [[ "$HOSTNAME" == "lakeoz" ]] ; then
        # if running on the Windows system, copy stuff to the linux system
        echo "======= copying convoar to nyxx"
        cd "$HERE"
        rsync -r -v --delete-after convoar "basil@nyxx:basil-git/Basiljs"
    fi
    echo "======= copying convoar to misterblue"
    for OAR in $OARS ; do
        BASENAME="$(basename -s .oar $OAR)"
        cd "$HERE"
        rsync -r -v --delete-after "convoar/$BASENAME" "${REMOTEACCT}@${REMOTEHOST}:${REMOTEBASE}/convoar"
    done
    cd "$HERE"
    rsync -v "convoar/index.json" "${REMOTEACCT}@${REMOTEHOST}:${REMOTEBASE}/convoar"
fi
