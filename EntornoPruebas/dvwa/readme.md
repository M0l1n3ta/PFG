## Build Container

docker build -t molineta/dvwa:2.0.1 .


##run container

docker run --rm -it -p 8086:80 molineta/dvwa:2.0.1 