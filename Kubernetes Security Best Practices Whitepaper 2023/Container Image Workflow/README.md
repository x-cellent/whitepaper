

this is applicable to two points:
- use admission controllers to enforce policies
- implement a secure workflow for container images

this is a pretty broad topic,

depending on how big the example should become we could build an example cluster:
- with a harbor registry
- running kyverno that has a policy that only allows signed images to be used
- and a script that mirrors some images from dockerhub to our harbor and signs it with cosign

1. pull nignx image from the internet
2. sign with cosign
3. push to our in-cluster-harbor
4. use the image from our in-cluster-harbor
5. show the kyverno messages when a signed/unsigned image is used (+ the option to block deployments of unsigned images)
