sudo curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
sudo chmod a+x /usr/local/bin/repo
git clone -b AU_LINUX_QSDK_NHSS.QSDK.12.5.R6_TARGET_ALL.12.5.6.2987.012.xml https://github.com/YK-Samgo/jdc-be65000-qsdk-compile.git
mkdir compile
mv fix_repo.sh compile/
cd compile
./fix_repo.sh
source qca/configs/qsdk/setup-environment -t ipq53xx -a 64 -p premium -d n -c n
repo sync
cp  ~/work/Actions-OpenWrt/Actions-OpenWrt/myconfig/kernel_config.64bit.qsdk ~/work/Actions-OpenWrt/Actions-OpenWrt/compile/qsdk/target/linux/feeds/ipq53xx/config-5.4

make -j$(nproc) || make -j1 V=s

