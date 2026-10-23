{ pkgs, ... }: {
  users.users.protono.packages = with pkgs; [
    (python314.withPackages (ps: with ps; [ 
      gdown 
      dnspython
      urllib3
      cryptography
      netaddr
      pip
      cherrypy
      cherrypy-cors
      requests
      beautifulsoup4
      numpy
      dnspython
      exifread
      mako
      lxml
      ipwhois
      ipaddr
      phonenumbers
      python-whois
      secure
      pyopenssl
      python-docx
      python-pptx
      networkx
      publicsuffixlist
      openpyxl
      pyyaml
      pillow
      pandas
    ]))
  ];
}
