FROM alpine
LABEL version='Velociraptor'
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
ENV MAXWAIT=10
ARG ADMIN_USER=admin
ARG ADMIN_PASSWORD=diggingdeeper
ARG URL=localhost
ARG FRONTEND_PORT=8000
ARG FRONTEND_HOST=velociraptor
# Frontend: ... "proxy_header":"X-Origin-IP to get the IP from the Client if you run Velo Frontend behind a reverse proxy. X-Origin-IP must be configured in the proxy 
# Frontend:... "use_plain_http":true,"proxy":"<PROXY>" if Frontend is running behind a reverse proxy to spare decryption overhead
# GUI: ... "use_plain_http":true if running GUI is behind reverse proxy
ARG CONFIG_OVERRIDE='{"Client":{"server_urls":["'${URL}':'${FRONTEND_PORT}'/"]},"GUI":{"links":[{"text":"Blauhaunt","new_tab":true,"type":"sidebar","url":"/Blauhaunt/"},{"text":"Blauhaunt_Latest","new_tab":true,"type":"sidebar","url":"/Blauhaunt/latest"}],"bind_address":"0.0.0.0","reverse_proxy":[{"route":"/Blauhaunt/","url":"file:///Blauhaunt/app/"},{"route":"/Blauhaunt/latest/","url":"https://cgosec.github.io/Blauhaunt/app/"}]},"Frontend":{"hostname":"'$FRONTEND_HOST'","bind_address":"0.0.0.0","bind_port":8000},"API":{"hostname":"velociraptor","bind_address":"0.0.0.0","bind_port":8001,"bind_scheme":"tcp"}}'
RUN echo $CONFIG_OVERRIDE
RUN cd output && \
        cp $(find | grep linux) /usr/bin/velociraptor && \
        velociraptor config generate --merge $CONFIG_OVERRIDE > /velo_config/server.config.yml  && \
        velociraptor  --config /velo_config/server.config.yml user add --role=administrator $ADMIN_USER $ADMIN_PASSWORD && \
        history -d 1
CMD velociraptor gui --logfile=/logs/velo.logs --datastore=/velo_data --max_wait=$MAXWAIT --nobrowser -c /velo_config/server.config.yml
