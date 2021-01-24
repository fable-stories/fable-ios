if [ -s ~/.bash_profile ]; then
  source ~/.bash_profile;
fi
tulsi --create-tulsiproj Fable --bazel /usr/local/bin/bazel --target //:Fable --outputfolder .