sudo curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
sudo chmod a+x /usr/local/bin/repo
git clone -b AU_LINUX_QSDK_NHSS.QSDK.12.5.R6_TARGET_ALL.12.5.6.2987.012.xml https://github.com/YK-Samgo/jdc-be65000-qsdk-compile.git
mkdir compile
mv fix_repo.sh compile/
cd compile
fix_repo.sh
repo sync
#cp $GITHUB_WORKSPACE/myconfig/kernel_config.64bit.qsdk $GITHUB_WORKSPACE/compile/qsdk/target/linux/feeeds/ipq53xx/config-5.4
