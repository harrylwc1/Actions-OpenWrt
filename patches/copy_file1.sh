for var in "$@"
do
    x=$x" -F files=@$var"
done
#curl -X POST http://127.0.0.1:8000/upload -F 'files=@multiple-example-1.txt' -F 'files=@multiple-example-2.txt'
# curl -X POST http://127.0.0.1:8000/upload -F 'files=@basicauth-example.txt' -u hello:world
curl -X POST http://r619ac2.ubddns.org:8080/upload $x -u $PASS
