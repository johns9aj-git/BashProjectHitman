# BashProjectHitman
Hitman is a port scanning tool that allows pen testers to scan their enviroment and identify any open ports within their network. It uses netcat for port scanning. Hitman also utilizes nmap for network scanning. It also allows you to save your output to files. 

Usage: "Usage: $0 -p <port_range> -r <target_ip(s)> [-o <output_file>]"

Usage: ./Hitman.sh -p 22,80,443 -r scanme.nmap.org -o Scan02.txt 

./Hitman.sh -p 22,80,443 -r scanme.nmap.org

Test Sites: 
scan.me.nmap.org

