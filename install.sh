
# docker
echo "$(tput setaf 6)$(tput bold)Installing Docker$(tput sgr0)"
#sudo apt-get install -y docker.io
docker --version
# docker-machine
echo "$(tput setaf 6)$(tput bold)Installing Docker machine$(tput sgr0)"
#base=https://github.com/docker/machine/releases/download/v0.14.0 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
#sudo install /tmp/docker-machine /usr/local/bin/docker-machine
docker-machine --version
# kubeadm, kubectl, kubeadm
echo "$(tput setaf 6)$(tput bold)Installing kubeadm, kubectl and kubeadm$(tput sgr0)"
#sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl
kubelet --version
kubeadm version
kubectl version
# Init k8s
echo "$(tput setaf 6)$(tput bold)Initialize the Kubernetes cluster$(tput sgr0)"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# Calico
echo "$(tput setaf 6)$(tput bold)Installing Calico$(tput sgr0)"
sudo kubectl apply -f https://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/etcd.yaml
sudo kubectl apply -f https://docs.projectcalico.org/master/getting-started/kubernetes/installation/rbac.yaml
sudo kubectl apply -f https://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/calico.yaml
sudo kubectl taint nodes --all node-role.kubernetes.io/master-
echo "$(tput setaf 6)$(tput bold)Waiting for Calico pods to start$(tput sgr0)"
sleep 5m
# helm
echo "$(tput setaf 6)$(tput bold)Installing Helm$(tput sgr0)"
sudo snap install helm
sudo cp $HOME/.kube/config /root/snap/helm/common/kube/
echo "$(tput setaf 6)$(tput bold)Creating account for tiller$(tput sgr0)"
sudo kubectl create -f ./rbac-config.yml
echo "$(tput setaf 6)$(tput bold)Starting helm with tiller$(tput sgr0)"
sudo helm init --service-account tiller
echo "$(tput setaf 6)$(tput bold)Securing helm$(tput sgr0)"
sudo kubectl --namespace=kube-system patch deployment tiller-deploy --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'
sudo helm version
# nginx ingress
echo "$(tput setaf 6)$(tput bold)Installing Nginx ingress controller$(tput sgr0)"
sudo helm install --name dev-ingress stable/nginx-ingress --namespace kube-system
echo "$(tput setaf 6)$(tput bold)Waiting for ingress controller to start$(tput sgr0)"
sleep 2m
