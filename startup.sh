#!/usr/bin/env bash
set -euo pipefail

# build the server config file from template
echo "Creating config file from template."
eval "echo \"$(< /terraria-server/serverconfig.tmpl)\"" > /terraria/serverconfig.txt

# download mods and build json file
if [[ ! -z "$TERRARIA_MODS_LIST" ]]; then
    # create the mods directory if absent
    if [[ ! -d /terraria/Mods ]]; then
        echo "Creating /terraria/Mods directory"
        mkdir /terraria/Mods
    fi

    # loop through mods and download
    echo "Downloading mods..."
    for mod in ${TERRARIA_MODS_LIST//,/ }; do
        filepath="/terraria/Mods/${mod}.tmod"
        # download the mod if missing or if redownload is set
        if [[ ! -e $filepath ]] || [[ $TERRARIA_MODS_REDOWNLOAD == "1" ]]; then
            echo "Downloading ${mod}.tmod"
            wget -q -O $filepath "http://javid.ddns.net/tModLoader/download.php?Down=mods/${mod}.tmod"
        else
            echo "Skipping download of ${mod}.tmod since it already exists."
        fi

        # check that the tmod file is an actual mod (the server always returns 200)
        if [[ $(file --mime-type -b $filepath) == 'text/plain' ]]; then
            echo "ERROR: ${mod}.tmod does not appear to be a valid mod file. Are you sure the name of the mod is correct?"
            exit 1
        fi
    done

    # populate enabled.json with the mods the server should use
    echo -ne ${TERRARIA_MODS_LIST} | jq -Rs 'split(",")' > /terraria/Mods/enabled.json
else
    echo "Skipping mods download since no mods are specified."
fi

# run the terraria server in a wrapper that catches sigterm
exec game-docker-wrapper -k "exit" -- /terraria-server/tModLoaderServer \
    -config /terraria/serverconfig.txt \
    -tmlsavedirectory /terraria \
    "$@"
