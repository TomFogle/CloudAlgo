FROM ubuntu:16.04

#MAINTANER Tom Fogle "youremail@domain.tld"

RUN apt-get update -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
    
RUN pip3 install flask
RUN pip3 install flask_sqlalchemy
    
#We copy just the requirements.txt first to leverage Docker cache
#COPY ./requirements.txt /app/requirements.txt

#WORKDIR /app

#RUN pip install -r requirements.txt

RUN mkdir app

COPY . /app

ENTRYPOINT [ "python3" ]

CMD [ "/app/api.py" ]