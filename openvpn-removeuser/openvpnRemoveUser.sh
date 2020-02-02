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

echo -e "\033[31m 这个是openvpn删除用户脚本！想要获取更多实用工具及脚本，请关注作者公众号获得更多实用脚本和工具：波哥的IT人生 Please continue to enter or ctrl+C to cancel \033[0m"
#sleep 5
read -p "Delete username: " Persons
init(){
yum -y install lrzsz expect 
}
removeuser(){

cd $bash_path
num=0
#for Persons in ${listPersons[@]}
#do

expect removeuser.exp $Persons $password

if [[ $? -eq 0 ]];then

docker run -v /data/openvpn:/etc/openvpn --rm -it registry.cn-hangzhou.aliyuncs.com/yangb/openvpn rm -f /etc/openvpn/pki/reqs/"$Persons".req
docker run -v /data/openvpn:/etc/openvpn --rm -it registry.cn-hangzhou.aliyuncs.com/yangb/openvpn rm -f /etc/openvpn/pki/private/"$Persons".key
docker run -v /data/openvpn:/etc/openvpn --rm -it registry.cn-hangzhou.aliyuncs.com/yangb/openvpn rm -f /etc/openvpn/pki/issued/"$Persons".crt
docker run -v /data/openvpn:/etc/openvpn --rm -it registry.cn-hangzhou.aliyuncs.com/yangb/openvpn rm -f /etc/openvpn/conf/"$Persons".ovpn
rm -rf  /data/openvpnConfig/"$Persons".ovpn
echo "$Persons 删除完成！"
else

echo "$Persons 删除错误！请根据日志修改参数，重新删除"
break;

fi

#done
}


main(){
init
removeuser
}
#main > ./setup.log 2>&1
main
