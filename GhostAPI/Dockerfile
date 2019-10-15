FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip

RUN pip3 install --upgrade pip
RUN pip3 install flask
RUN pip3 install flask_sqlalchemy
RUN pip3 install textdistance[benchmark]

RUN mkdir app

COPY . /app

ENTRYPOINT [ "python3" ]

CMD [ "/app/api.py" ]