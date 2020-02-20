Simple ansible playbook and roles to setup a very basic kubernetes cluster on your laptop. It is based on the upstream instructions here: https://kubernetes.io/docs/setup/production-environment/

The cluster comprises of:

* 1 master node
* 2 worker nodes

Nodes are running centos 7, containerd and k8s 1.17. The playbook also sets up the Calico CNI.

To get started, ensure that you have KVM enabled on your laptop. On debian/ubuntu you can use the following command:
```
sudo apt install qemu-kvm libvirt-daemon libvirt-daemon-system network-manager libguestfs-tools
```

The script in scripts/setup_vms.sh can be used to create the virtual machines for you. Otherwise create the VMs manually using CentOS 7 and update the inventory to match the host names/IP addresses you have created.

To run the playbook use:
```
ansible-playbook -i inventory/hosts configure_k8s.yml
```

Once up and running you can use the local kubeconfig to connect to the cluster:

```
$ kubectl --kubeconfig=k8s-master-kubeconfig get nodes
NAME                      STATUS   ROLES    AGE     VERSION
k8s-master.local          Ready    master   4m      v1.17.3
k8s-worker-node-1.local   Ready    <none>   3m30s   v1.17.3
k8s-worker-node-2.local   Ready    <none>   3m29s   v1.17.3

$ kubectl --kubeconfig=k8s-master-kubeconfig get pods --all-namespaces=true
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-5b644bc49c-2gb64   1/1     Running   0          2m29s
kube-system   calico-node-4rcb5                          1/1     Running   0          2m17s
kube-system   calico-node-95jcf                          1/1     Running   0          2m29s
kube-system   calico-node-v9m6c                          1/1     Running   0          2m16s
kube-system   coredns-6955765f44-7t8fn                   1/1     Running   0          2m29s
kube-system   coredns-6955765f44-klqst                   1/1     Running   0          2m29s
kube-system   etcd-k8s-master.local                      1/1     Running   0          2m41s
kube-system   kube-apiserver-k8s-master.local            1/1     Running   0          2m41s
kube-system   kube-controller-manager-k8s-master.local   1/1     Running   0          2m41s
kube-system   kube-proxy-4s4d2                           1/1     Running   0          2m16s
kube-system   kube-proxy-8lbqk                           1/1     Running   0          2m17s
kube-system   kube-proxy-wsjx7                           1/1     Running   0          2m29s
kube-system   kube-scheduler-k8s-master.local            1/1     Running   0          2m41s

```
