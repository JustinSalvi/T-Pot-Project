# How to deploy T-Pot (Honeypot) using Ubuntu Server 24.04.3 with VirtualBox!

## Project Summary

This is the archictecture and a quick run down on what the logical connections are going to be used for, along with the docker containers, tools, and system requirements needed for this project!

![](https://imgur.com/ZYI46nN.png)

### Components

- **Oralce VirtualBox**
- **Ubuntu Server 24.04.3**

# System Requirements

Depending on the [supported Linux distro images](#choose-your-distro), hive / sensor, installing on [real hardware](#running-on-hardware), in a [virtual machine](#running-in-a-vm) or other environments there are different kind of requirements to be met regarding OS, RAM, storage and network for a successful installation of T-Pot (you can always adjust `~/tpotce/docker-compose.yml` and `~/tpotce/.env`to your needs to overcome these requirements).
<br><br>

| T-Pot Type | RAM  | Storage   | Description                                                                                      |
|:-----------|:-----|:----------|:-------------------------------------------------------------------------------------------------|
| Hive       | 16GB | 256GB SSD | As a rule of thumb, the more honeypots, sensors & data, the more RAM and storage is needed.      |
| Sensor     | 8GB  | 128GB SSD | Since honeypot logs are persisted (~/tpotce/data) for 30 days, storage depends on attack volume. |

## Required Ports
Besides the ports generally needed by the OS, i.e. obtaining a DHCP lease, DNS, etc. T-Pot will require the following ports for incoming / outgoing connections. Review the [T-Pot Architecture](#technical-architecture) for a visual representation. Also some ports will show up as duplicates, which is fine since used in different editions.

| Port                                                                                                                                  | Protocol | Direction | Description                                                                                         |
|:--------------------------------------------------------------------------------------------------------------------------------------|:---------|:----------|:----------------------------------------------------------------------------------------------------|
| 80, 443                                                                                                                               | tcp      | outgoing  | T-Pot Management: Install, Updates, Logs (i.e. OS, GitHub, DockerHub, Sicherheitstacho, etc.        |
| 11434                                                                                                                                 | tcp      | outgoing  | LLM based honeypots: Access your Ollama installation                                                |
| 64294                                                                                                                                 | tcp      | incoming  | T-Pot Management: Sensor data transmission to hive (through NGINX reverse proxy) to 127.0.0.1:64305 |
| 64295                                                                                                                                 | tcp      | incoming  | T-Pot Management: Access to SSH                                                                     |
| 64297                                                                                                                                 | tcp      | incoming  | T-Pot Management Access to NGINX reverse proxy                                                      |
| 5555                                                                                                                                  | tcp      | incoming  | Honeypot: ADBHoney                                                                                  |
| 22                                                                                                                                    | tcp      | incoming  | Honeypot: Beelzebub  (LLM required)                                                                 |
| 5000                                                                                                                                  | udp      | incoming  | Honeypot: CiscoASA                                                                                  |
| 8443                                                                                                                                  | tcp      | incoming  | Honeypot: CiscoASA                                                                                  |
| 443                                                                                                                                   | tcp      | incoming  | Honeypot: CitrixHoneypot                                                                            |
| 80, 102, 502, 1025, 2404, 10001, 44818, 47808, 50100                                                                                  | tcp      | incoming  | Honeypot: Conpot                                                                                    |
| 161, 623                                                                                                                              | udp      | incoming  | Honeypot: Conpot                                                                                    |
| 22, 23                                                                                                                                | tcp      | incoming  | Honeypot: Cowrie                                                                                    |
| 19, 53, 123, 1900                                                                                                                     | udp      | incoming  | Honeypot: Ddospot                                                                                   |
| 11112                                                                                                                                 | tcp      | incoming  | Honeypot: Dicompot                                                                                  |
| 21, 42, 135, 443, 445, 1433, 1723, 1883, 3306, 8081                                                                                   | tcp      | incoming  | Honeypot: Dionaea                                                                                   |
| 69                                                                                                                                    | udp      | incoming  | Honeypot: Dionaea                                                                                   |
| 9200                                                                                                                                  | tcp      | incoming  | Honeypot: Elasticpot                                                                                |
| 22                                                                                                                                    | tcp      | incoming  | Honeypot: Endlessh                                                                                  |
| 80, 443, 8080, 8443                                                                                                                   | tcp      | incoming  | Honeypot: Galah  (LLM required)                                                                     |
| 8080                                                                                                                                  | tcp      | incoming  | Honeypot: Go-pot                                                                                    |
| 80, 443                                                                                                                               | tcp      | incoming  | Honeypot: H0neytr4p                                                                                 |
| 21, 22, 23, 25, 80, 110, 143, 443, 993, 995, 1080, 5432, 5900                                                                         | tcp      | incoming  | Honeypot: Heralding                                                                                 |
| 3000                                                                                                                                  | tcp      | incoming  | Honeypot: Honeyaml                                                                                  |
| 21, 22, 23, 25, 80, 110, 143, 389, 443, 445, 631, 1080, 1433, 1521, 3306, 3389, 5060, 5432, 5900, 6379, 6667, 8080, 9100, 9200, 11211 | tcp      | incoming  | Honeypot: qHoneypots                                                                                |
| 53, 123, 161, 5060                                                                                                                    | udp      | incoming  | Honeypot: qHoneypots                                                                                |
| 631                                                                                                                                   | tcp      | incoming  | Honeypot: IPPHoney                                                                                  |
| 80, 443, 8080, 9200, 25565                                                                                                            | tcp      | incoming  | Honeypot: Log4Pot                                                                                   |
| 25                                                                                                                                    | tcp      | incoming  | Honeypot: Mailoney                                                                                  |
| 2575                                                                                                                                  | tcp      | incoming  | Honeypot: Medpot                                                                                    |
| 9100                                                                                                                                  | tcp      | incoming  | Honeypot: Miniprint                                                                                 |
| 6379                                                                                                                                  | tcp      | incoming  | Honeypot: Redishoneypot                                                                             |
| 5060                                                                                                                                  | tcp/udp  | incoming  | Honeypot: SentryPeer                                                                                |
| 80                                                                                                                                    | tcp      | incoming  | Honeypot: Snare (Tanner)                                                                            |
| 8090                                                                                                                                  | tcp      | incoming  | Honeypot: Wordpot                                                                                   |

### Steps

1. Essentially once you spin up the vm and perform a `sudo apt update && sudo apt upgrade`.

*NOTE: YOU WILL NEED TO ENABLE OPEN SSH ON THE SERVER IN ORDER TO GET A PUTTY SESSION IN PLACE TO BE ABLE TO COPY AND PASTE SINCE UBUNTU SERVER WILL NOT LET YOU!*

2. Type in `sudo apt install openssh-server` this will enable you to have ssh enabled in your server for secure access via Putty session.

*You will need to setup port forwarding as pictured down below.*

![](https://imgur.com/vQxTkWO.png)

3. Once that is finished, then create a file `nano docker-install.sh` to load [dependecies](https://wiki.kitpro.us/en/articles/docker-script) that are needed for the docker containers. 

4. Then git clone [here](https://github.com/telekom-security/tpotce).

# Results

This is what the interface should look like once the git clone is loaded onto the server.

![](https://imgur.com/SqKEt6q.png) 

![](https://imgur.com/864DrrD.png)

# Attack Narratives and Metrics

*Suricata Dashboard*

![](https://imgur.com/82Od6mc.png)

![](https://imgur.com/DzmyXM9.png)

*Kibana Dashboard*

![](https://imgur.com/SOK86ZQ.png)

![](https://imgur.com/1PfqesK.png)

# OSINT Gatherings

I conducted an attack on the T-pot using a Kali box and utilized Spiderfoot to conduct Open-source intelligence against the attacking box

![](https://imgur.com/aO3w0w6.png)

Here are the results against the attacker box after a successful scan

![](https://imgur.com/6vqgxRk.png)

# Conclusion

This deployment of a T-Pot was seamless and showed how robust open-source analytic tools can be used to enhance visibility of attackers across the world and the TTP's that they are using to hack into a system. T-Pot exposed how attackers actually probe, fingerprint, and interact with systems. Seeing real-world attack traffic in tools like Elastic and Suricata revealed patterns that don’t always show up in sanitized lab environments: automated bot behavior, brute-force strategies, exploit chaining, and the speed at which exposed services are discovered once placed online.

---

This project is subject to further iterations and refinements. Viewer discretion is advised as the findings are based on a controlled environment and may not perfectly emulate real-world operational conditions.

For more insight on the details of this project, please refer [here!](https://github.com/telekom-security/tpotce) 
