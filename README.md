# Yet another Ubuntu AMI Finder

This one, however, finds AMIs using the AWS cli.

## Why?

Other finders use the cloud images page at 
https://cloud-images.ubuntu.com/locator/ec2/, or other similar indexes.
These tools serve the purpose pretty well, but sometimes have dependencies
that don't serve the consuming project very well.

I've been using [aws-cli][1] for this recently, however the Makefiles
for such invocations get a little unwieldy.

Canonical uploads their images to AWS using a pretty easy to predict
structure, which makes setting this up in script pretty easy.

## What you need

 * [aws-cli][1]
 * `bash` 4+.

## Supported releases

Note that pre-release versions may not be supported due to the image
namespace being different than most, if not all other images
(`ubuntu/images-milestone` versus `ubuntu/images`).

## Usage

```
    Usage: ./ubuntu-ami.sh OPTIONS

      --release RELEASE        The release name (ie: trusty)
      --image_type IMGTYPE     The image type (ie: hvm-ebs)
      --arch ARCH              The image arch (amd64 or i386)
      --full                   Print all images found
```

The default behaviour is to print the most recent AMI found in the search.

## Output

The output is formatted as `[CreationDate,ImageId,RootDeviceName]`. This
generally gives you enough info to be able to set up a new root device
instead of the one in the AMI.

Note that on instance store images, the last column will come up as
`None`. The output is ordered so that the data that will always be useful
will be at the start (the first field being creation date).

## License

```
Copyright 2016 PayByPhone Technologies Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[1]: https://github.com/aws/aws-cli
