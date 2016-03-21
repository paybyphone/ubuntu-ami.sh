#!/usr/bin/env bash
#
# Copyright 2016 PayByPhone Technologies Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

declare -A args=(
  [full]="false"
  [release]=""
  [image_type]=""
  [arch]=""
)

canonical_ownerid="099720109477"

declare -A image_types=(
  [hvm-ebs]="hvm"
  [hvm-io1]="hvm-io1"
  [hvm-ssd]="hvm-ssd"
  [hvm-instance]="hvm-instance"
  [pv-ebs]="ebs"
  [pv-io1]="ebs-io1"
  [pv-ssd]="ebs-ssd"
  [pv-ebs]="ebs"
)

declare -A releases=(
  [wily]="wily-15.10"
  [vivid]="vivid-15.04"
  [utopic]="utopic-14.10"
  [trusty]="trusty-14.04"
  [saucy]="saucy-13.10"
  [raring]="raring-13.04"
  [quantal]="quantal-12.10"
  [precise]="precise-12.04"
  [oneric]="oneric-11.10"
  [natty]="natty-11.04"
  [maverick]="maverick-10.10"
  [lucid]="lucid-10.04"
  [karmic]="karmic-9.10"
  [hardy]="hardy-8.04"
)

# Print help.
help() {
  cat <<EOS
    Usage: $0 OPTIONS

      --release RELEASE        The release name (ie: trusty)
      --image_type IMGTYPE     The image type (ie: hvm-ebs)
      --arch ARCH              The image arch (amd64 or i386)
      --full                   Print all images found

Supported releases: ${!releases[@]}
Supported images: ${!image_types[@]}
EOS
}

# Parse arguments.
arg_parse() {
  if [ "$#" == "0" ]; then
    echo "ERROR: No arguments supplied." 1>&2
    help
    exit 1
  fi
  while (( "$#" )); do
    case $1 in
      --release)
        shift
        args[release]=$1
        ;;
      --image_type)
        shift
        args[image_type]=$1
        ;;
      --arch)
        shift
        args[arch]=$1
        ;;
      --full)
        shift
        args[full]="true"
        ;;
      --help)
        help
        exit 1
        ;;
      *)
        echo "ERROR: Invalid argument: $1" 1>&2
        help
        exit 1
    esac
    shift
  done
}

# validate release name. 
validate_release() {
  __release=${args[release]}
  __release_string=${releases[$__release]}
  if [ -z "$__release_string" ]; then
    echo "ERROR: Unsupported release: $__release" 1>&2
    help
    exit 1
  fi
}

# validate image type.
validate_image_type() {
  __image_type=${args[image_type]}
  __image_type_string=${image_types[$__image_type]}
  if [ -z "$__image_type_string" ]; then
    echo "ERROR: Unsupported image type: $__image_type" 1>&2
    help
    exit 1
  fi
}

# validate arch
validate_arch() {
  __arch=${args[arch]}
  if [ "$__arch" != "amd64" ] && [ "$__arch" != "i386" ]; then
    echo "ERROR: Unsupported arch type: $__arch" 1>&2
    help
    exit 1
  fi
}


# validate arguments added by argparse()
arg_validate() {
  validate_release
  validate_image_type
  validate_arch
}

run_search() {
  __out=$(
    __release=${args[release]}
    __release_string=${releases[$__release]}
    __image_type=${args[image_type]}
    __image_type_string=${image_types[$__image_type]}
    aws ec2 describe-images \
      --filters Name=name,Values="ubuntu/images/${__image_type_string}/ubuntu-${__release_string}-amd64*" \
                Name=owner-id,Values=${canonical_ownerid} \
      --query "Images[*].[CreationDate,ImageId,RootDeviceName]" --output text
  )
  __status=$?
  if [ "${__status}" != "0" ]; then
    echo "ERROR: aws ec2 describe-images exited with code ${__status}" 1>&2
    exit 1
  fi
  out=$(echo "$__out" | sort -k1 -rn)
}

show() {
  __text=$1
  if [ "${args[full]}" == "true" ]; then
    echo "$__text"
  else
    echo "$__text" | head -n1
  fi
}

arg_parse "$@"
arg_validate
run_search
show "$out"
