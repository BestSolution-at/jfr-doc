#!/bin/sh

# Execute in the bin-dir of your Java-Install

./java -XX:StartFlightRecording:filename=/tmp/rec.jfr -version
./jfr metadata /tmp/rec.jfr > /Users/tomschindl/git/jfr-doc/openjdk-$1.jfr