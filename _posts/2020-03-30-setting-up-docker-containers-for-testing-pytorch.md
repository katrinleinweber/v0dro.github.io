---
layout: post
title: Setting up Docker containers for testing pytorch
date: 2020-03-30 19:18 +0900
---

# Introduction

Frequently we run into issues while developing pytorch that fail only
for a particular build configuration that is very hard to reproduce
on your local machine. Facebook uses docker containers for running
CI setups for various build configurations, which you can also use
for building your own local Docker images in order to reproduce the
issue easily. This post is how you can use the Docker functionality
on QGPU in order to build such a Docker image on QGPU1.

# First steps

The first step is to ask an admin (Pearu/Sameer/Dharhas) to add you
to the `docker` group on QGPU1. Once you're on this group, find the
Amazon ECR API access keys on the facebook quip document. `Docker`
and `nvidia-docker` are already installed so you need not install
them.

Then install the Amazon ECR client for your user from [here](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html).
Then run `aws ecr get-login` which will prompt you for login
credentials, and then subsequently run for automatic login.

In order to know which docker image you need, you must know its full
name first. The name can be found from the circleCI build. The amazon
ECR name can be a little different so just find the name from the
output of the `aws ecr describe-repositories` command. Use
in this manner to find which repo you need (typically the name
of your failing build on circleCI):

``` bash
aws ecr describe-repositories | grep -C 3 xenial
```
From the output of this pickup the exact `repositoryName` value
and replace it in the `repo_name` variable in the below ruby script
in order to get the full string that be the name of your docker image:

``` ruby
require 'json'

repo_name = "pytorch/pytorch-linux-xenial-cuda10.2-cudnn7-py3-gcc7"

puts "logging in..."
`aws ecr get-login --no-include-email | bash`

images = JSON.parse `aws ecr describe-images --repository-name #{repo_name}`
image_tag = images['imageDetails'][-1]['imageTags'][0]
repo_info = JSON.parse `aws ecr describe-repositories --repository-names #{repo_name}`
uri = repo_info['repositories'][0]['repositoryUri']

puts "Docker image: #{uri}:#{image_tag}"
```

You can then create your own docker image using a `Dockerfile` like so:
``` Dockerfile
# Insert the SHA key after the image name.
FROM <insert docker image name here>

ENV MAX_JOBS=20

RUN conda install -y hypothesis

RUN cd workspace \
    && git submodule sync --recursive \
    && git submodule update --init --recursive \
    && TORCH_CUDA_ARCH_LIST=Turing python setup.py install --cmake
```
The default docker container is built for a different GPU in some cases so
it is important to specify the `TORCH_CUDA_ARCH_LIST` env variable.

# Further reading

* https://github.com/pytorch/pytorch/wiki/Docker-image-build-on-CircleCI
