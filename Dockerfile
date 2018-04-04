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

# download command
#RUN ln -s $LEGI_PATH/scripts/legi.downlad.sh $TARBALLS_PATH /usr/bin/download && chmod +x /usr/bin/download

COPY ./scripts/bin/* /usr/bin/

# cat $LEGI_PATH/echo -e "#!/bin/sh\npython -m legi.download $TARBALLS_PATH" > /usr/bin/download && chmod +x /usr/bin/download

# # tar2sqlite command
# RUN echo -e "#!/bin/sh\npython -m legi.tar2sqlite $TARBALLS_PATH/legilibre.sqlite $TARBALLS_PATH" > /usr/bin/tar2sqlite && chmod +x /usr/bin/tar2sqlite

# # update command
# RUN echo -e "#!/bin/sh\n/usr/bin/download\n/usr/bin/tar2sqlite" > /usr/bin/update && chmod +x /usr/bin/update

