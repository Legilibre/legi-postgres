FROM python:alpine

RUN apk add --update git gcc python-dev libxml2-dev libxslt-dev musl-dev wget libarchive libarchive-dev

RUN python -m ensurepip

# preload requirements so we benefit the docker image caching layer
RUN pip install libarchive-c lxml tqdm

ENV LEGI_PATH /usr/src/app
ENV TARBALLS_PATH /tarballs

WORKDIR $LEGI_PATH

COPY . .
#RUN git clone https://github.com/Legilibre/legi.py.git $LEGI_PATH/legi.py

WORKDIR $LEGI_PATH/legi.py

RUN pip install -r requirements.txt

COPY ./scripts/bin/* /usr/bin/

