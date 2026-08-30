{ config, pkgs, lib, ... }: let
  torrentDir = "${config.home.homeDirectory}/Downloads/torrents";
  sessionDir = "${config.home.homeDirectory}/.local/share/rtorrent/session";
  watchDir = "${config.home.homeDirectory}/.local/share/rtorrent/watch";
in {
  home.packages = [
    pkgs.rtorrent
  ];
  home.activation.createRtorrentDirectories =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p \
        "${torrentDir}" \
        "${sessionDir}" \
        "${watchDir}"
    '';

  home.file.".rtorrent.rc".text = ''
    directory = ${torrentDir}
    session = ${sessionDir}
    port_range = 50000-50000
    port_random = no
    check_hash = yes
    encryption = allow_incoming,try_outgoing,enable_retry
    dht = auto
    peer_exchange = yes
    udp_tracker = yes
    schedule = watch_directory,5,5,load.start=${watchDir}/*.torrent
  '';
}

