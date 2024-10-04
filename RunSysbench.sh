!/bin/sh


if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

#non-Rocky
# apt-get update -y
# apt-get install sysbench

#Rocky
#Boot into the shell
# sudo systemctl set-default multi-user.target
# sudo yum update
# rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
# yum -y install epel-release
# yum -y update
# sudo yum install sysbench



#file system i/o performance test
sysbench --test=fileio --file-total-size=150G prepare
sysbench --test=fileio --file-total-size=128G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run 
sysbench --test=fileio --file-total-size=128G cleanup

# test CPU workloads
sysbench cpu run
sysbench --test=cpu --cpu-max-prime=20000 --num-threads=2 run

# test threads
sysbench --test=threads --thread-locks=1 --max-time=20s run

# test mutex workloads with threads
sysbench --test=mutex --num-threads=64 run

# test memory workloads
sysbench --test=memory --num-threads=4 run
sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=read run
sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=write run



