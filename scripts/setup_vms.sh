#!/bin/sh

# Edit for your own use. You will need to pull the centos 7 generic cloud image
# from http://cloud.centos.org/centos/7/images/ and update CENTOS_IMAGE with the
# path.
#
# The VMs are deployed with avahi-daemon installed and enabled so you can use
# mdns to connect to them. 
#
# Update BRIDGE to virbr0 if you are running this locally on your laptop and you
# don't intend to connect from an external source. Otherwise ensure you have setup
# bridge networking on your external interface.

STORAGE_POOL_ROOT=/var/lib/libvirt/images
BRIDGE=virbr0
DOMAIN=local
TIMEZONE=Europe/London
SSH_KEY=$( cat ~/.ssh/id_rsa.pub )
CENTOS_IMAGE=/data/vm_images/CentOS-7-x86_64-GenericCloud.qcow2
VM_MEMORY=2048
VM_VCPU=2
VM_DISKSIZE=20G
NODES="k8s-master k8s-worker-node-1 k8s-worker-node-2"

# Create cloudinit iso
create_cloud_init() {
  echo "Setting up cloud-init iso for ${VM}"

  # Create meta-data
  cat << EOF > ${STORAGE_POOL_DIR}/meta-data
instance-id: ${VM}
local-hostname: ${VM}
EOF

  # Create user-data
  cat << EOF > ${STORAGE_POOL_DIR}/user-data
#cloud-config
preserve_hostname: False
hostname: ${VM}
fqdn: ${VM}.${DOMAIN}
ssh_authorized_keys:
  - ${SSH_KEY}
output:
  all: ">> /var/log/cloud-init.log"
timezone: ${TIMEZONE}
runcmd:
  - systemctl stop network && systemctl start network
  - yum -y remove cloud-init
  - yum -y install avahi
  - systemctl enable --now avahi-daemon
EOF

  # Create cloud-init.iso
  mkisofs -o ${STORAGE_POOL_DIR}/${VM}-config.iso -V cidata -J -r ${STORAGE_POOL_DIR}/user-data ${STORAGE_POOL_DIR}/meta-data

}

create_storage_pool_dir() {
  echo "Creating storage pool dir for ${VM}"
  if [ -d ${STORAGE_POOL_DIR} ] ; then
    echo "Looks like VM is already created - exiting."
    exit 1
  else
    mkdir ${STORAGE_POOL_DIR}
  fi
}

create_root_disk() {
  echo "Setting up base image for ${VM}"
  qemu-img create -f qcow2 -o preallocation=metadata ${STORAGE_POOL_DIR}/${VM}-vda.qcow2 ${VM_DISKSIZE}
  virt-resize --expand /dev/sda1 ${CENTOS_IMAGE} ${STORAGE_POOL_DIR}/${VM}-vda.qcow2
}

create_storage_pool() {
  echo "Setting up storage pool for ${VM}"
  cd ${STORAGE_POOL_DIR}
  virsh pool-create-as --name ${VM} --type dir --target ${STORAGE_POOL_DIR}
}

create_vm() {
  echo "Setting up virtual machine ${VM}"
  cd ${STORAGE_POOL_DIR}
  virt-install --import --name ${VM} \
  --memory ${VM_MEMORY} --vcpus ${VM_VCPU} --cpu host \
  --disk ${VM}-vda.qcow2,format=qcow2,bus=virtio \
  --disk ${VM}-config.iso,device=cdrom \
  --network bridge=${BRIDGE},model=virtio \
  --os-type=linux \
  --os-variant=centos7.0 \
  --graphics none \
  --noautoconsole
}

for VM in ${NODES}
do
  STORAGE_POOL_DIR=${STORAGE_POOL_ROOT}/${VM}
  create_storage_pool_dir
  create_cloud_init
  create_root_disk
  create_storage_pool
  create_vm
done

