# velociraptor_container
A Dockerfile and a docker-compose stack for automatically building the latest velociraptor version (designed for testing only)

#Usage

      git clone https://github.com/cgosec/velociraptor_container.git

      cd velociraptor_container

      cp .env.sample .env

change data in .env file as needed

    docker-compose up -d

or

    docker compose up -d

depending on your version

now you should be able to access the GUI via your IP / URL and the specified GUI Port using basic authentication logon with the initial credentials in your .env file

If you change the password, you should delete your browser data since I had some issues with a crashing server. Same when you have issues after recrating the container.
