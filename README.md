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
docker run -d --name=teamcity-agent-1 --link teamcity:teamcity --privileged -e TEAMCITY_SERVER=http://teamcity:8111 tomatensuppe/teamcity-agent:latest
```