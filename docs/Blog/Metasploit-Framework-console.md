# Metasploit Framework console on Docker. (with workspace)
Sep 20, 2019

## Summary

I am a security specialist. I love Linux and containers. I would not say I like Kali Linux and bloated software. I use Metasploit Framework on Docker with workspace. Although you can start using the MSF docker out of the box, you need a database for using the workspace. Here is how.

## Containers are everywhere in my life

Over the past few years, I started to like Docker and containerization in general. Before that, I had some resistance against containerization. Compared to VM, I saw VMs more secure and isolated. But now I have a different opinion. Although some of the security concerns about containers are true, at least for now, the benefits of containers are more appealing to me now.
I have started using Docker wherever I can in my job or even personal life. I use Docker to build my automated security testing platform at work, and I use them to integrate my security testing tools. I run my services such as OpenVPN and Plex on Docker at home. They are everywhere in my life.

I would not say I like to use Kali Linux because of 1. I am not particularly eager to run VM all the time. 2. Kali Linux is bloated. 3. There are so many tools that I don’t even use. Instead, I use Arch Linux as my daily driver with a minimum number of packages installed. I use the Blackarch strap on my Arch Linux to get security tools or build the tools on Docker.
One of the tools that I use is Metasploit Framework, and thanks to the Rapid7 team, there is a docker for MSF, which is getting updates every day or even sometimes twice a day. Although you can start using the MSF docker out of the box, you need a database for using the workspace.

## MSF Console on Docker

You need [MSF](https://hub.docker.com/r/metasploitframework/metasploit-framework) and [Postgres](https://hub.docker.com/_/postgres) docker. You also need to set up a docker network.
First, create a directory in your home directory for MSF files. You also need a directory to keep Postgres data. Let’s keep it in the same place with MSF files.

``` bash 
mkdir $HOME/.msf4
mkdir $HOME/.msf4/database
```

## Network
You need a docker network to assign a fixed IP to each container. Let’s create a network with a subnet of 172.18.0.0/16, and we call it msf.

``` bash 
docker network create --subnet=172.18.0.0/16 msf
```

## Database

Now we need the database. Here we are going to use Postgres 11 with alpine based os. Let’s assign it to network msf and give IP 172.18.0.2. You need to mount a volume to keep the data, and you also need to set the value to Postgres’s username, password and database name.

``` bash
docker run --ip 172.18.0.2 --network msf --rm --name postgres -v "${HOME}/.msf4/database:/var/lib/postgresql/data" -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=msf -d postgres:11-alpine
```

## MSF
Now we can run MSF on Docker, but we need to set database URL (including username, password, and database name in URL) for the first time. You also need to mount the volume to save the data. Lastly, you need to map the range of ports that MSF will use.

``` bash
docker run --rm -it --network msf --name msf --ip 172.18.0.3 -e DATABASE_URL='postgres://postgres:postgres@172.18.0.2:5432/msf' -v "${HOME}/.msf4:/home/msf/.msf4" -p 8443-8500:8443-8500 metasploitframework/metasploit-framework
```

### Save database setting

You can save the database setting in MSF. To do so, inside the MSF console, execute db_save. Now you can run MSF docker without setting database URL.

``` bash
docker run --rm -it -u 0 --network msf --name msf --ip 172.18.0.3 -v "${HOME}/.msf4:/home/msf/.msf4" -p 8443-8500:8443-8500 metasploitframework/metasploit-framework
```
## MSF function in .bashrc

If you are using Linux, you can also use the below function in your bashrc. First, it will check if the msf network exists; if not, it will create the network. Then it will check if Postgres docker is running; if not, it will start the Postgres docker. Lastly, it will start the MSF docker.

``` bash
function msf-docker() {
 if [ -z "$(docker network ls | grep -w msf)" ];
 then
 docker network create --subnet=172.18.0.0/16 msf
 fi
 if [ -z "$(docker ps -a | grep -w postgres)" ];
 then
 docker run --ip 172.18.0.2 --network msf --rm --name postgres -v "${HOME}/.msf4/database:/var/lib/postgresql/data" -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=msf -d postgres:11-alpine
 fi
 docker run --rm -it -u 0 --network msf --name msf --ip 172.18.0.3 -v "${HOME}/.msf4:/home/msf/.msf4" -p 8443-8500:8443-8500 metasploitframework/metasploit-framework
}
```
 
 If you need help with any of these, drop me a message.