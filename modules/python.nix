{ pkgs, ... }: {
  users.users.protono.packages = with pkgs; [
    (python314.withPackages (ps: with ps; [ 
      beautifulsoup4
      cherrypy
      cherrypy-cors
      cryptography
      dnspython
      dnspython
      exifread
      gdown 
      ipaddr
      ipwhois
      lxml
      mako
      netaddr
      networkx
      numpy
      openpyxl
      pandas
      phonenumbers
      pillow
      pip
      publicsuffixlist
      pyopenssl
      python-docx
      python-pptx
      python-whois
      pyyaml
      requests
      rich
      secure
      urllib3
      yt-dlp
    ]))
  ];
}
