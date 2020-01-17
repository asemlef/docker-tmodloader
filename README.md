# docker-tmodloader

A docker container for a tModLoader server. This is designed to be require as little manual setup as possible, and will automatically create a new world with the desired mods on first start. See the [Configuration](#configuration) section for details.

**IMPORTANT NOTE:** Stopping this container triggers a save of the game world before exiting, which is a slow process. By default docker will hard kill the container after 10 seconds, and depending on the size and complexity of your world this may not be enough time to complete the save. It is **highly** recommended to use `docker stop -t 60` to extend the hard kill timeout.

## Usage

Sample command to create a container.

```
docker create -dt \
    --name="terraria" \
    -p 7777:7777 \
    -v <path to data>:/terraria \
    -e TERRARIA_SERVER_PASSWORD="password" \
    -e TERRARIA_SERVER_MOTD="Hello world"
    -e TERRARIA_SERVER_MAXPLAYERS=50 \
    -e TERRARIA_WORLD_NAME="Terraria" \
    -e TERRARIA_MODS_LIST="ThoriumMod,CheatSheet" \
    asemlef/tmodloader
```

## Configuration

The tModLoader server is configured using environment variables, which are based on the options in the [Terraria server config file](https://terraria.gamepedia.com/Server#Server_config_file).

### Environment Variables

| Variable | Function | Default Value |
| :----: | --- | --- |
| `TERRARIA_SERVER_PASSWORD` | The password for the server | None |
| `TERRARIA_SERVER_MAXPLAYERS` | Maximum players allowed on server | 8 |
| `TERRARIA_SERVER_MOTD` | Message of the day | "Please don't cut the purple trees!" |
| `TERRARIA_SERVER_LANGUAGE` | The server's language | "en/US" |
| `TERRARIA_SERVER_SECURE` | Enables stricter anticheat if set to 1 | 0 |
| `TERRARIA_WORLD_NAME` | The name of the world to create | "World" |
| `TERRARIA_WORLD_SIZE` | The size of the world to create, from 1-3 | 3 |
| `TERRARIA_WORLD_DIFFICULTY` | The difficulty of the world to create; 0=Normal, 1=Expert | 0 |
| `TERRARIA_WORLD_SEED` | Seed to create the world from (default: none) | None |
| `TERRARIA_MODS_LIST` | Comma-separated list of mods to use; see below for details | None |
| `TERRARIA_MODS_REDOWNLOAD` | Enables redownloading of existing mods if set to 1 | 0 |

### Mods

Mods can be automatically downloaded from the [tModLoader Mod Browser](http://javid.ddns.net/tModLoader/DirectModDownloadListing.php) by setting the `TERRARIA_MODS_LIST` variable to a comma-separated list of mods. The name of each mod in the list should match the filename in the download link on the mod browser. For example, `TERRARIA_MODS_LIST="ThoriumMod,CheatSheet"` would download and use the Thorium and Cheat Sheet mods.

By default the container will only download mods once and will never update them. If you would instead prefer the container to redownload up-to-date copies of every mod on each start, set `TERRARIA_MODS_REDOWNLOAD=1`.

You can also manually place mod files in `/terraria/Mods` rather than auto-download them from the mod browser. Be sure to edit `/terraria/Mods/enabled.json` when doing so.

### Using an Existing World

While the container is designed to use a fresh world that's auto-created on first start, it's possible to use an existing world file instead. To do so, place the file into `/terraria/Worlds` and set `TERRARIA_WORLD_NAME` to the name of that world.

## Notes

* Don't change any persistent server settings (password, motd, maxplayers, etc) in the server console. The changes won't persist through container restarts.
* The Terraria server binary ignores SIGTERM, so [game-docker-wrapper](https://github.com/iagox86/game-docker-wrapper) is used to catch it and gracefully exit. Special thanks to iagox86 for making the tool and helping with troubleshooting.
