#! /bin/sh

set -e

testbin=_build/hateoas
testout=test.output

if [ ! -f $testbin ]
then
    echo "Test binary ($testbin) not found, please run build.sh first"
    exit 1
fi

($testbin > $testout 2>&1) &
pid=$!
echo "Server started with pid $pid"

printf "Waiting for server to accept connections "
while ! grep -q "Serving at" $testout
do
    sleep 1
    printf "."
    if ! kill -0 $pid
    then
        echo "Server failed to start, check output for details:"
        cat $testout
        exit 1
    fi
done
printf " ready\n"

echo "Running tests"

failures=""

curltest()
{
    url="$1"
    expected="$2"
    actual=$(curl --silent http://localhost:3000$url)
    echo "$actual" | grep -q "$expected" || {
        printf "x"
        failures="$failures\n$url: expected to see '$expected', got:\n$actual\n"
        return
    }
    printf "."
}

curltest "/" "Hypermedia As The Engine Of Application State"

curltest "/counter" "Count: 0"
curl --silent -X POST http://localhost:3000/counter >/dev/null
curltest "/counter" "Count: 1"

curltest "/contacts" "Alice, alice@example.com"

echo

kill "$pid"

if [ -n "$failures" ]
then
    echo "Failures:"
    echo "$failures"
    exit 1
else
    echo "All tests passed!"
fi
