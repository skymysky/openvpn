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

echo -e "\033[31m 这个是openvpn添加用户脚本,想要获取更多实用工具及脚本，请关注作者公众号获得更多实用脚本和工具：波哥的IT人生！Please continue to enter or ctrl+C to cancel \033[0m"
#sleep 5
init(){
yum -y install lrzsz expect 
}
adduser(){

cd $bash_path
num=0
for Persons in ${listPersons[@]}
do

expect adduser.exp $Persons $password

if [[ $? -eq 0 ]];then

docker run -v /data/openvpn:/etc/openvpn --rm registry.cn-hangzhou.aliyuncs.com/yangb/openvpn ovpn_getclient $Persons > /data/openvpn/conf/$Persons.ovpn

cp /data/openvpn/conf/$Persons.ovpn /data/openvpnConfig/ 

sed -i "7c remote $ipaddr $openvpnPort $sla" /data/openvpnConfig/$Persons.ovpn
sz /data/openvpnConfig/$Persons.ovpn
#rm -rf /data/openvpn/conf/$Persons.ovpn.bak

echo "$Persons 配置完成！"
else
echo "参数有误，配置错误！"
break;

fi

done

}


adduser_single(){
cd $bash_path
read -p "adduser username: " Persons

expect adduser.exp $Persons $password

if [[ $? -eq 0 ]];then
docker run -v /data/openvpn:/etc/openvpn --rm registry.cn-hangzhou.aliyuncs.com/yangb/openvpn ovpn_getclient $Persons > /data/openvpn/conf/$Persons.ovpn

cp /data/openvpn/conf/$Persons.ovpn /data/openvpnConfig/ 

sed -i "7c remote $ipaddr $openvpnPort $sla" /data/openvpnConfig/$Persons.ovpn

#sz /data/openvpn/conf/$Persons.ovpn.bak
#rm -rf /data/openvpn/conf/$Persons.ovpn.bak
echo "$Persons 配置完成！"
else
echo "参数有误，配置错误！"
fi


}


main(){
init
if [[ $more == "1" ]];then
adduser
else
adduser_single
fi
}
#main > ./setup.log 2>&1
main
