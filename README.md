brender_erl_server
=====

An OTP application

Build
-----

    $ rebar3 compile


build docker dev :
docker build -t erl_dev --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)  -f Dockerfile.erlang.dev  .


run docker dev :
docker run --rm -u $(id -u):$(id -g) -it -v $(pwd):/usr/app erl_dev

