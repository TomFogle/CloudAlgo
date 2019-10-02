FROM ubuntu:16.04

#MAINTAINER Tom Fogle "youremail@domain.tld"

RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
#RUN sudo apt-get install psycopg2 libpq-dev python-dev

RUN pip3 install flask
RUN pip3 install flask_sqlalchemy
#RUN pip3 install psycopg2
RUN pip install textdistance[benchmark]



#COPY ./requirements.txt /app/requirements.txt

#WORKDIR /app

#RUN pip install -r requirements.txt

RUN mkdir app

COPY . /app

ENTRYPOINT [ "python3" ]

CMD [ "/app/api.py" ]