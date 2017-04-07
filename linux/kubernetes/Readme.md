# Kubernetes Guestbook Fun

## About 

This is a built from: https://coreos.com/kubernetes/docs/latest/kubernetes-on-vagrant.html

It needs direct access to the Internet since it downloads all the images from gcr.io. It does not work with a proxy. 


## How to use it

Configure kubectl: 
```
cd multi-tier/coreos-kubernetes/multi-node/vagrant
export KUBECONFIG="${KUBECONFIG}:$(pwd)/kubeconfig"
unset http_proxy https_proxy

./kubectl version
Client Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.4", GitCommit:"7243c69eb523aa4377bce883e7c0dd76b84709a1", GitTreeState:"clean", BuildDate:"2017-03-07T23:53:09Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"5", GitVersion:"v1.5.4+coreos.0", GitCommit:"97c11b097b1a2b194f1eddca8ce5468fcc83331c", GitTreeState:"clean", BuildDate:"2017-03-08T23:54:21Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
```

Access the machines: 
```
vagrant ssh c1|w1|e1
```

Funny thing, vagrant needs http_proxy, kubectl cannot work with it.

To access the dashboard: 
```
./kubectl proxy 
```

It is now available on http://127.0.0.1:8001/ui

## Intricacies 

You can peek at the iptables configuration done by kube-proxy on the work nodes with:
```
sudo iptables -t nat -nvL
```

Kube-proxy actually leverages iptables so you will see more as opposed to the userspace implementation.

I deployed the Guestbook and exposed it on an external IP. 

This looks like this: 
```
[bmarincas@localhost vagrant]% ./kubectl get services                         
NAME           CLUSTER-IP   EXTERNAL-IP    PORT(S)    AGE
frontend       10.3.0.252   172.17.4.101   80/TCP     16h
kubernetes     10.3.0.1     <none>         443/TCP    1d
redis-master   10.3.0.103   <none>         6379/TCP   20h
redis-slave    10.3.0.241   <none>         6379/TCP   17h
```

You can see bellow that the pod is deployed on the node 172.17.4.201. 
And that it has the IP address: 10.2.59.13.

```
[bmarincas@localhost vagrant]% ./kubectl get pods
NAME                           READY     STATUS    RESTARTS   AGE
frontend-456680569-fsgp5       1/1       Running   0          16h
redis-master-343230949-jxzcw   1/1       Running   0          20h
redis-slave-500459085-m84kw    1/1       Running   0          17h
redis-slave-500459085-wpkww    1/1       Running   0          17h

[bmarincas@localhost vagrant]% ./kubectl describe pod frontend-456680569-fsgp5
Name:           frontend-456680569-fsgp5
Namespace:      default
Node:           172.17.4.201/172.17.4.201
Start Time:     Thu, 06 Apr 2017 19:58:28 +0530
Labels:         app=guestbook
                pod-template-hash=456680569
                tier=frontend
Status:         Running
IP:             10.2.59.13
Controllers:    ReplicaSet/frontend-456680569
Containers:
  php-redis:
    Container ID:       docker://dcd179bdc1b7df32bc97975d7dd16c10f90878227f0f7c6f313ab07902eabf53
    Image:              gcr.io/google-samples/gb-frontend:v4
    Image ID:           docker-pullable://gcr.io/google-samples/gb-frontend@sha256:d44e7d7491a537f822e7fe8615437e4a8a08f3a7a1d7d4cb9066b92f7556ba6d
    Port:               80/TCP
    Requests:
      cpu:              100m
      memory:           100Mi
    State:              Running
      Started:          Thu, 06 Apr 2017 19:58:29 +0530
    Ready:              True
    Restart Count:      0
    Volume Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-1zk8w (ro)
    Environment Variables:
      GET_HOSTS_FROM:   env
Conditions:
  Type          Status
  Initialized   True 
  Ready         True 
  PodScheduled  True 
Volumes:
  default-token-1zk8w:
    Type:       Secret (a volume populated by a Secret)
    SecretName: default-token-1zk8w
QoS Class:      Burstable
Tolerations:    <none>
No events.
```

On the worker node where the frontend is deployed iptables is setup like this:
```
core@w1 ~ $ sudo iptables -t nat -nL |grep frontend
KUBE-MARK-MASQ  all  --  10.2.59.13           0.0.0.0/0            /* default/frontend: */
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            /* default/frontend: */ tcp to:10.2.59.13:80
KUBE-MARK-MASQ  tcp  -- !10.2.0.0/16          10.3.0.252           /* default/frontend: cluster IP */ tcp dpt:80
KUBE-SVC-GYQQTB6TY565JPRW  tcp  --  0.0.0.0/0            10.3.0.252           /* default/frontend: cluster IP */ tcp dpt:80
KUBE-MARK-MASQ  tcp  --  0.0.0.0/0            172.17.4.101         /* default/frontend: external IP */ tcp dpt:80
KUBE-SVC-GYQQTB6TY565JPRW  tcp  --  0.0.0.0/0            172.17.4.101         /* default/frontend: external IP */ tcp dpt:80 PHYSDEV match ! --physdev-is-in ADDRTYPE match src-type !LOCAL
KUBE-SVC-GYQQTB6TY565JPRW  tcp  --  0.0.0.0/0            172.17.4.101         /* default/frontend: external IP */ tcp dpt:80 ADDRTYPE match dst-type LOCAL
KUBE-SEP-ACK5ZHRIFEXLTW3H  all  --  0.0.0.0/0            0.0.0.0/0            /* default/frontend: */
```

On a closer look: 
```
core@w1 ~ $ docker ps 
CONTAINER ID        IMAGE                                                                  COMMAND                  CREATED             STATUS              PORTS               NAMES
dcd179bdc1b7        gcr.io/google-samples/gb-frontend:v4                                   "apache2-foreground"     3 hours ago         Up 3 hours                              k8s_php-redis.8f2bd26c_frontend-456680569-fsgp5_default_4d42085e-1ad5-11e7-815e-080027f7d13f_aa22f51f

core@w1 ~ $ PID=$(docker inspect --format {{.State.Pid}} dcd179bdc1b7)

core@w1 ~ $ sudo nsenter --target $PID --mount --uts --ipc --net --pid ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth0@if18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
    link/ether 0a:58:0a:02:3b:0d brd ff:ff:ff:ff:ff:ff
    inet 10.2.59.13/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f4df:1aff:febb:3a29/64 scope link 
       valid_lft forever preferred_lft forever
```
We can now see that the docker container does indeed have the IP address: 10.2.59.13.

So, on the worker nodes we can do this on 10.3.0.252:
```
core@c1 ~ $ wget http://10.3.0.252
--2017-04-06 18:33:26--  http://10.3.0.252/
Connecting to 10.3.0.252:80... connected.
HTTP request sent, awaiting response... 200 OK

core@c1 ~ $ ping 10.3.0.252
PING 10.3.0.252 (10.3.0.252) 56(84) bytes of data.
^C
--- 10.3.0.252 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3086ms
```

While on 10.2.59.13: 
```
core@c1 ~ $ wget http://10.2.59.13 
--2017-04-06 18:33:56--  http://10.2.59.13/
Connecting to 10.2.59.13:80... connected.
HTTP request sent, awaiting response... 200 OK

core@c1 ~ $ ping 10.2.59.13
PING 10.2.59.13 (10.2.59.13) 56(84) bytes of data.
64 bytes from 10.2.59.13: icmp_seq=1 ttl=63 time=1.08 ms
```

This is fine since service IPs are meant to load balance the port access, while flannel provides POD-to-POD communication.

The network fabric provider is Flannel...
```
core@w1 ~ $ cat /run/flannel/subnet.env
FLANNEL_NETWORK=10.2.0.0/16
FLANNEL_SUBNET=10.2.59.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true

core@w1 ~ $ cat /run/flannel/flannel_docker_opts.env 
DOCKER_OPT_BIP="--bip=10.2.59.1/24"
DOCKER_OPT_IPMASQ="--ip-masq=false"
DOCKER_OPT_MTU="--mtu=1450"

core@w1 ~ $ cat /run/flannel/options.env             
FLANNELD_IFACE=172.17.4.201
FLANNELD_ETCD_ENDPOINTS=http://172.17.4.51:2379
```

```
core@w1 ~ $ ifconfig cni0
cni0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 10.2.59.1  netmask 255.255.255.0  broadcast 0.0.0.0
        inet6 fe80::8828:2aff:feb6:82f1  prefixlen 64  scopeid 0x20<link>
        ether 0a:58:0a:02:3b:01  txqueuelen 1000  (Ethernet)
        RX packets 160844  bytes 30379299 (28.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 166698  bytes 145605089 (138.8 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

core@w1 ~ $ brctl show
bridge name     bridge id               STP enabled     interfaces
cni0            8000.0a580a023b01       no              veth0fb8bcdf
                                                        veth1c1c704b
                                                        veth20b9845d
                                                        veth25b6c887
                                                        veth2663b8b2
                                                        vethaa94d3a3
                                                        vethcf6ed286
                                                        vethfdf0fe3b
docker0         8000.0242a456d704       no
```

## References: 

* https://coreos.com/kubernetes/docs/latest/kubernetes-networking.html
* https://github.com/jpetazzo/nsenter
* https://github.com/containernetworking/cni
* https://github.com/containernetworking/cni/blob/master/Documentation/flannel.md





