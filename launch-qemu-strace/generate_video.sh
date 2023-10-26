#!/bin/bash

DIR=$(pwd)
SESSION=demo
VIDEO=kubevirt-debug-qemu-strace

setup_common() {
        git pull
        make
        tmux new-session -d -s $SESSION
        tmux send-keys -t $SESSION 'PS1="$ "'
        tmux send-keys -t $SESSION C-m
        tmux send-keys -t $SESSION clear
        tmux send-keys -t $SESSION C-m

        tmux set -t $SESSION window-status-format '#W'
        tmux set -t $SESSION window-status-current-format '#W'
        tmux set -t $SESSION status-left ''
        tmux set -t $SESSION window-status-separator ''

        tmux set -t $SESSION window-status-style 'bg=colour1 fg=colour15 bold'
        tmux set -t $SESSION status-right ''
        tmux set -t $SESSION status-style 'bg=colour1 fg=colour15 bold'
        tmux set -t $SESSION status-right-style 'bg=colour1 fg=colour15 bold'
        tmux send-keys -t $SESSION "cd ${DIR}" ENTER
        sleep 1
}

script() {
        IFS='
'
        for line in $(eval printf '%s\\\n' \$SCRIPT_${1}); do
                unset IFS
                case ${line} in
                "@")    tmux send-keys -t $SESSION C-m  ;;
                "%"*)   sleep ${#line}                  ;;
                *)      cmd_write "${line}"             ;;
                esac
                IFS='
'
        done
        unset IFS
}

cmd_write() {
        __str="${@}"
        while [ -n "${__str}" ]; do
                __rem="${__str#?}"
                __first="${__str%"$__rem"}"
                if [ "${__first}" = ";" ]; then
                        tmux send-keys -t $SESSION -l '\;'
                else
                        tmux send-keys -t $SESSION -l "${__first}"
                fi
                sleep 0.05 || :
                __str="${__rem}"
        done
        sleep 2
        tmux send-keys -t $SESSION "C-m"
}


teardown_common() {
        sleep 5
        tmux kill-session -t $SESSION
        sleep 5
}

SCRIPT_build='
# This demo shows how to strace QEMU with KubeVirt without rebuilding the
# virt-launcher image and using KubeVirt sidecars
#
# We now build the container image containing the debugging tools
#
# Later we will use the script wrap_qemu_strace.sh to launch QEMU with strace
clear
%%
cat wrap_qemu_strace.sh
%%
clear
# In this example we are installing strace in the debug tools directory inside
# the container image
%%
cat Dockerfile.debug
%%
clear
# Now we build and push the image into the cluster registry
./build_push_debug_image.sh
%%
clear
# We can use it as base to populate a PVC with a k8s job
cat debug-tools-pvc.yaml
%%
clear
%
kubectl apply -f debug-tools-pvc.yaml
%%%
kubectl get pvc
%%%
clear
cat populate-job-pvc.yaml
%%%
clear
kubectl apply -f populate-job-pvc.yaml
%%%
kubectl wait --for=condition=complete job populate-pvc
%%
kubectl get po
kubectl delete job populate-pvc --wait=false
%%%
clear
# Now we can create the configmap for modifying the XML
cat configmap.yaml
%%%
clear
%
kubectl apply -f configmap.yaml
%%
kubectl get configmap
%%
clear
%%
# Then, we launch the VM with the sidecar and debugging tool
clear
%
cat debug-vmi.yaml |head -n8
%%%
clear
%
kubectl apply -f debug-vmi.yaml
%
kubectl get po
%
kubectl wait --for=condition=ready vmi vmi-debug-tools
%%%%
kubectl get vmi
%%%%
POD=$( kubectl get po  -l kubevirt.io=virt-launcher  -o "jsonpath={ .items[0].metadata.name }" )
%
clear
%
# We can exec into the pod and grep for strace if it has been launched correctly
%
kubectl exec -ti $POD -- ps -ef
%%%
# We can also verify the output file
%
kubectl exec -ti $POD -- ls /var/run/debug/logs/strace.out
%%
clear
%
# We can now delete the VM
%
kubectl delete --wait=false vmi vmi-debug-tools
%%%%
clear
%
# Even without the VM we can retrive the output log as we saved it into a PVC
# For example, we can create a simple pod to attach the PVC
%
cat fetch-logs-pvc.yaml
%%%
clear
%
kubectl apply -f fetch-logs-pvc.yaml
%%%
kubectl wait --for=condition=ready pod fetch-logs
%%%
kubectl get po
%%
# Then, we can copy the output file locally
kubectl cp fetch-logs:/vol/logs/strace.out kubevirt-demo-vm.strace
%%%
kubectl delete po fetch-logs --wait=false
%%
clear
%
cat kubevirt-demo-vm.strace |head -n15
%%%
clear
%
## Thanks for watching!
'

printf '\e[8;22;80t'
setup_common

tmux send-keys -t $SESSION -l 'reset'
tmux send-keys -t $SESSION C-m
tmux rename-window -t $SESSION 'KubeVirt demo: debug QEMU with strace'
echo "please give the password"
sleep 10
echo "starting the demo"

asciinema rec --overwrite ${VIDEO}.cast -c 'tmux attach -t $SESSION' &
sleep 1
script build

teardown_common

