#got orignal config from router at /proc/config.gz | gunzip > /tmp/config-5.4.xxx

sudo cp patches/copy_file.sh /usr/bin/
sudo chmod 755 /usr/bin/copy_file.sh
sudo curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
sudo chmod a+x /usr/local/bin/repo
git clone -b AU_LINUX_QSDK_NHSS.QSDK.12.5.R6_TARGET_ALL.12.5.6.2987.012.xml https://github.com/YK-Samgo/jdc-be65000-qsdk-compile.git
mkdir compile
mv fix_repo.sh compile/
cd compile
./fix_repo.sh

source qca/configs/qsdk/setup-environment -t ipq53xx -a 32 -p premium -d n -c n
#source qca/configs/qsdk/setup-environment -t ipq53xx -a 64 -p premium -d n -c n

repo sync


#cp  ~/work/Actions-OpenWrt/Actions-OpenWrt/myconfig/kernel_config.qsdk64 ~/work/Actions-OpenWrt/Actions-OpenWrt/compile/qsdk/target/linux/feeds/ipq53xx/config-5.4
cp  ~/work/Actions-OpenWrt/Actions-OpenWrt/myconfig/kernel_config.qsdk32 ~/work/Actions-OpenWrt/Actions-OpenWrt/compile/qsdk/target/linux/feeds/ipq53xx/config-5.4

cd qsdk
#cp ~/work/Actions-OpenWrt/Actions-OpenWrt/myconfig/config.qsdk.64bit .config
cp ~/work/Actions-OpenWrt/Actions-OpenWrt/myconfig/config.qsdk.32bit .config

make kernel_oldconfig
make -j$(nproc) || make -j1 V=s

mkdir  -p ~/work/Actions-OpenWrt/Actions-OpenWrt/compile/qsdk/targets/ipq*/generic/drivers

zip -r qsdk_64bit_`date +%d%h%y_%H%M`.zip  ~/work/Actions-OpenWrt/Actions-OpenWrt/compile/qsdk/targets/ipq*/generic/
