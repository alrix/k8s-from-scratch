Pod Purposes
## Control Plane Components
#kube-apiserver
The Kubernetes API server validates and configures data for the api objects which include pods, services, replicationcontrollers, and others. The API Server services REST operations and provides the frontend to the cluster’s shared state through which all other components interact.

#etcd
Consistent and highly-available key value store used as Kubernetes’ backing store for all cluster data.

#kube-controller-manager
Control Plane component that runs controller processes.

Logically, each controller is a separate process, but to reduce complexity, they are all compiled into a single binary and run in a single process.

These controllers include:

* Node Controller: Responsible for noticing and responding when nodes go down.
* Replication Controller: Responsible for maintaining the correct number of pods for every replication controller object in the system.
* Endpoints Controller: Populates the Endpoints object (that is, joins Services & Pods).
* Service Account & Token Controllers: Create default accounts and API access tokens for new namespaces

#kube-scheduler
Control Plane component that watches for newly created pods with no assigned node, and selects a node for them to run on.

Factors taken into account for scheduling decisions include individual and collective resource requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference and deadlines

## Node Components
#kubelet
An agent that runs on each node in the cluster. It makes sure that containers are running in a pod.

The kubelet takes a set of PodSpecs that are provided through various mechanisms and ensures that the containers described in those PodSpecs are running and healthy. The kubelet doesn’t manage containers which were not created by Kubernetes

#kube-proxy
kube-proxy is a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept.

kube-proxy maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of your cluster.

kube-proxy uses the operating system packet filtering layer if there is one and it’s available. Otherwise, kube-proxy forwards the traffic itself

# Container runtime
The container runtime is the software that is responsible for running containers. In this cluster we use containerd.

##Addons
#coredns
CoreDNS is a flexible, extensible DNS server that can serve as the Kubernetes cluster DNS.

