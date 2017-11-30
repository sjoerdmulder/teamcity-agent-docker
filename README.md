Teamcity build agent
========================

When starting the image as container you must set the TEAMCITY_SERVER environment variable to point to the teamcity server e.g.
```
docker run -e TEAMCITY_SERVER=http://localhost:8111
```

Optionally you can specify your ownaddress using the `TEAMCITY_OWN_ADDRESS` variable.

Linking example
--------
```
docker run -d --name=teamcity-agent-1 --link teamcity:teamcity --privileged -e TEAMCITY_SERVER=http://teamcity:8111 smallimprovements/teamcity-agent-docker:latest
```

Example for Docker-in-Docker
--------
### Unix
```
docker run -d \
  --link teamcity:teamcity \
  --name teamcity-agent-1 \
  -e AGENT_NUMBER=1 \
  -e TEAMCITY_SERVER=http://teamcity:8111 \
  -e ADDITIONAL_GID=`stat -c %g /var/run/docker.sock` \
  -e ADDITIONAL_GROUP=`stat -c %G /var/run/docker.sock` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  smallimprovements/teamcity-agent-docker:0.12.oracle"
```

### OSX

```
docker run -d \
  --link teamcity:teamcity \
  --name teamcity-agent-1 \
  -e AGENT_NUMBER=1 \
  -e TEAMCITY_SERVER=http://teamcity:8111 \
  -e ADDITIONAL_GID=`stat -f "%p" /var/run/docker.sock` \
  -e ADDITIONAL_GROUP=`stat -f "%p" /var/run/docker.sock` \
  -v /var/run/docker.sock:/var/run/docker.sock \
  smallimprovements/teamcity-agent-docker:0.12.oracle"
```
