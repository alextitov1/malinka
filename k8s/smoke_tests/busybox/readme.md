kubectl create namespace my-busybox

kubectl run myshell1 -it --rm --image busybox -n my-busybox -- sh