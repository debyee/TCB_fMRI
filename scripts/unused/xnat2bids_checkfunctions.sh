#!/bin/bash

#--------- Variables ---------

version=v0.1.2                                 # version of xnat2bids being used


#--------- Look at full list of inputs ---------

singularity run --rm -it -v ${bids_root_dir}:/data/xnat/bids-export   \
brownbnc/xnat-tools:${version} xnat2bids --help


