FROM alpine
LABEL version="Velociraptor"
ENV MAXWAIT=10
ARG ADMIN_USER=admin
ARG ADMIN_PASSWORD=diggingdeeper
ARG URL=localhost
EXPOSE 8000
EXPOSE 8001
EXPOSE 8003
EXPOSE 8889
RUN mkdir /logs && \
        mkdir /velo_data && \
        mkdir /velo_config
RUN apk update && \
        apk upgrade && \
        apk add make && \
        apk add git && \
        apk add gcc && \
        apk add build-base && \
        apk add nodejs npm && \
        apk add mingw-w64-gcc
RUN wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz && \
        rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.4.linux-amd64.tar.gz && \
        export PATH=$PATH:/usr/local/go/bin
RUN git clone https://github.com/Velocidex/velociraptor.git && \
        cd velociraptor/gui/velociraptor && \
        npm install && \
        make build
RUN git clone https://github.com/cgosec/Blauhaunt
WORKDIR /velociraptor
RUN export PATH=$PATH:/usr/local/go/bin && \
        go version && \
        go get github.com/UnnoTed/fileb0x
RUN export PATH=$PATH:/root/go/bin:/usr/local/go/bin && \
        make linux && \
        make windows
RUN cd output && \
        cp $(find | grep linux) /usr/bin/velociraptor && \
        # velociraptor config generate > -o "{'GUI': {'public_url': '$URL', 'links': [{'text': 'Blauhaunt', 'new_tab': true, 'type': 'sidebar', 'url': '/Blauhaunt/'}], 'bind_address': '0.0.0.0', 'reverse_proxy': [{'route': '/Blauhaunt/', 'url': 'file:///Blauhaunt/app/'}]}}" /velo_config/server.config.yml && \
RUN     velociraptor  --config /velo_config/server.config.yml user add --role=administrator $ADMIN_USER $ADMIN_PASSWORD && \
        history -d 1
CMD velociraptor gui --logfile=/logs/velo.logs --datastore=/velo_data --max_wait=$MAXWAIT --nobrowser -c /velo_config/server.config.yml
