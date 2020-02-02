#!/bin/bash
#b8_yang@163.com
#source ./base.config
bash_path=$(cd "$(dirname "$0")";pwd)
source $bash_path/base.config

if [[ "$(whoami)" != "root" ]]; then
	echo "please run this script as root ." >&2
	exit 1
fi

#log="./setup.log"  #操作日志存放路径
#fsize=2000000
#exec 2>>$log  #如果执行过程中有错误信息均输出到日志文件中

echo -e "\033[31m 这个是openvpn安装部署脚本！请关注作者公众号获得更多实用脚本和工具：波哥的IT人生 Please continue to enter or ctrl+C to cancel \033[0m"
#sleep 5


yum_init(){
num=0
while true ; do
let num+=1
yum -y install iotop iftop yum-utils net-tools rsync git lrzsz expect gcc gcc-c++ make cmake libxml2-devel openssl-devel curl curl-devel unzip sudo ntp libaio-devel wget vim ncurses-devel autoconf automake zlib-devel  python-devel bash-completion
if [[ $? -eq 0 ]] ; then

echo "初始化安装环境配置完成！！！"
break;
else
if [[ num -gt 3 ]];then
echo "你登录 "$masterip" 瞅瞅咋回事？装三遍没装上yum包"
break
fi
echo "FK!~没成功？哥再来一次！！"
fi
done
}

mkdir_path(){
test -d /data/openvpnConfig
if [[ $? -ne 0 ]];then
mkdir -p /data/openvpnConfig
fi

test -d /data/openvpn
if [[ $? -ne 0 ]];then
mkdir -p /data/openvpn
fi
test -d /data/openvpn/conf
if [[ $? -ne 0 ]];then
mkdir -p /data/openvpn/conf
fi
}

#install docker
install_docker() {
test -d /etc/docker
if [[ $? -eq 0 ]];then
echo "docker已经安装完毕!!!"
else
mkdir -p /etc/docker
yum-config-manager --add-repo  https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y --setopt=obsoletes=0 docker-ce-18.09.4-3.el7
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://gpkhi0nk.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl enable docker
systemctl restart docker
echo "docker已经安装完毕!!!"
fi
}

install_docker_compace() {
cd $bash_path
test -f /usr/local/bin/docker-compose
if [[ $? -eq 0 ]];then
echo "docker-compose 安装完毕!!"
else

cp $bash_path/docker-compose /usr/local/bin/
chmod +x /usr/local/bin/docker-compose 
docker-compose --version
echo "docker-compose 安装完毕!!"
fi

}

# config docker
config_docker(){
grep "tcp://0.0.0.0:2375" /usr/lib/systemd/system/docker.service
if [[ $? -eq 0 ]];then
echo "docker API接口已经配置完毕"
else
sed -i "/^ExecStart/cExecStart=\/usr\/bin\/dockerd -H tcp:\/\/0\.0\.0\.0:2375 -H unix:\/\/\/var\/run\/docker.sock" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker.service
echo "docker API接口已经配置完毕"
fi
}



install_openvpn(){

cd $bash_path
num=0
while true ; do
let num+=1
docker pull registry.cn-hangzhou.aliyuncs.com/yangb/openvpn

if [[ $? -eq 0 ]] ; then

docker run -v /data/openvpn:/etc/openvpn --rm registry.cn-hangzhou.aliyuncs.com/yangb/openvpn ovpn_genconfig -u $sla://$ipaddr

#docker run -v /data/openvpn:/etc/openvpn --rm -it registry.cn-hangzhou.aliyuncs.com/yangb/openvpn ovpn_initpki

expect installopenvpn.exp $password
docker ps -a |grep -w openvpn && docker rm -f openvpn
docker run --name openvpn -v /data/openvpn:/etc/openvpn -d -p $openvpnPort:1194  --restart=always --cap-add=NET_ADMIN registry.cn-hangzhou.aliyuncs.com/yangb/openvpn

echo "环境搭建完毕"
break;
else
if [[ num -gt 3 ]];then
echo "尝试3次后，镜像下载错误！请检查网络"
break
fi
echo "FK!~没成功？哥再来一次！！"
fi
done

}




main(){
mkdir_path
yum_init
install_docker
config_docker
install_docker_compace

install_openvpn


}
main > ./setup.log 2>&1
#main
