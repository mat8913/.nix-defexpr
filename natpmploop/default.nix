{ writeScriptBin
, python3
}:

let

  python = python3.withPackages(ps: [ ps.py-natpmp ]);

in

writeScriptBin "natpmploop" ''
  #!${python}/bin/python3

  import natpmp
  import time
  import sys


  def main(gateway):
      port = None

      while True:
          x = natpmp.map_port(natpmp.NATPMP_PROTOCOL_TCP, 0, 0, 3600, gateway)
          if x.public_port != port:
              port = x.public_port
              print("TCP Port:", port)
          x = natpmp.map_port(natpmp.NATPMP_PROTOCOL_UDP, 0, 0, 3600, gateway)
          if x.public_port != port:
              port = x.public_port
              print("UDP Port:", port)
          time.sleep(45)


  if __name__ == "__main__":
      if len(sys.argv) != 2:
          print(f"Usage: {sys.argv[0]} <gateway>")
          sys.exit(1)

      gateway = sys.argv[1]
      main(gateway)
''
