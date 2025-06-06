git clone https://github.com/openwrt/openwrt x-wrt
cp -r $GITHUB_WORKSPACE/myconfig/* $GITHUB_WORKSPACE/x-wrt/

cd x-wrt

git checkout 57a6d97ddf8f6541a52e0f8fad8c6f47685a1bc3
cp -r $GITHUB_WORKSPACE/package/* $GITHUB_WORKSPACE/x-wrt/package/

./scripts/feeds update -a               
./scripts/feeds install -a -f
cp config.aarch64.3 .config
