
# Bind
## [Full Instructions] (https://linoxide.com/setting-dns-server-docker)
-----
## Instructions
## Configurations
- Build DNS
```
sudo docker pull sameersbn/bind:9.9.5-20170129
```
OR
```
sudo docker-compose -f docker-compose.bind.yaml up -d
```
- Start DNS
```
sudo docker run --name bind -d --restart=always \
	 --publish 53:53/tcp --publish 53:53/udp --publish 10000:10000/tcp \
	 --volume bind:/data \
	  sameersbn/bind:9.9.5-20170129
```
OR
```
sudo docker-compose -f docker-compose.bind.yaml up -d
```
- Login to DNS using [web interface] (https://localhost:10000) with default username:`root` and password: `password` add zone and addresses by following instructions given below. 
	-  Create master zone (e.g. `5gucl.com`) with following specifications `{Zone Type:Forward,Domain Name:[5gucl.com], Email address:<use own email>,<Keep rest of settings as default>}`
	- Start from Bind Home page: Select Zone name in `Existing DNS Zones`. Select `Address` button and add new address with following specifications. `{Name:[gw.5gucl.com],Address:<IP of the target>,Time-to-live:60s}` and apply changes using `Apply Zone` button. Add one address entry for the Domain name (e.g. `5gucl.com`), and rest as per your requirement.
	- Start from Bind Home page: Add `forwading and transfer` to google DNS `8.8.8.8` and `8.8.4.4`
	- `Apply configurations` after each change 

********
# CoreDNS
## Full instructions can be found in 
[burkeazbill/docker-coredns/](https://github.com/burkeazbill/docker-coredns/)
----
## Instructions
### Configurations
Edit the config/Corefile as follows:

- Rename the file it is referencing to match your domain (change the 5gucl.com part of the filename to yourdomain.whatever)
- Uncomment the file type you wish to use (hosts/file)
- Edit hosts file (5gucl.com.hosts), adding entries for eacy of your hosts in the respective format.

### Run the DNS server
- Ubuntu: Disable and stop the systemd-resolved service
```
sudo systemctl disable systemd-resolved.service # To disable resolvd permanently
sudo systemctl stop systemd-resolved
sudo service network-manager restart
```
- Start DNS container
```
sudo docker-compose -f docker-compose.coredns.yaml up -d
```
- Force build and start after changing the configurations
```
sudo docker-compose -f docker-compose.coredns.yaml up --build --force-recreate --no-deps -d
```

- (OR) Use simply run docker from the command line? Example shows call for latest image. 
```
docker run -m 128m --expose=53 --expose=53/udp -p 53:53 -p 53:53/udp -v "$PWD"/config:/etc/coredns --name coredns burkeazbill/docker-coredns -conf /etc/coredns/Corefile
```

- Stop DNS container 
```
sudo docker-compose -f docker-compose.coredns.yaml kill; sudo docker-compose -f docker-compose.coredns.yaml rm -f; sudo docker ps -a
```
****
# Test the DNS
## With dig
```
dig @localhost gateway.5gucl.com
```

This should result in the output including an ANSWER SECTION that shows gateway.5gucl.com resolves to 192.168.138.1 as follows:

```
$ dig @localhost gateway.example.com


; <<>> DiG 9.10.6 <<>> @localhost gateway.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47780
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;gateway.example.com.		IN	A

;; ANSWER SECTION:
gateway.example.com.	3600	IN	A	192.168.1.1

;; AUTHORITY SECTION:
example.com.		3600	IN	NS	a.iana-servers.net.
example.com.		3600	IN	NS	b.iana-servers.net.

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Jul 05 23:24:04 EDT 2018
;; MSG SIZE  rcvd: 169
```
## With nslookup
nslookup -debug  gw.5gucl.com
-----
## Learn more

- [Corefile explained](https://coredns.io/2017/07/23/corefile-explained/)
- [Quickstart Guide](https://coredns.io/2017/07/24/quick-start/)
