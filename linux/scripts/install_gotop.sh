#!/bin/bash

github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
  grep -Po '"tag_name": "\K.*?(?=")'
}

release=$(github_latest_release "xxxserxxx/gotop")
unamem=$(uname -m)
curl -SL  https://github.com/xxxserxxx/gotop/releases/download/$release/gotop_$release\_$(uname -s)_${unamem/x86_64/amd64}.tgz -o $TMP/gotop.tgz
tar -xf $TMP/gotop.tgz -C $TMP
sudo install $TMP/gotop /usr/bin/
