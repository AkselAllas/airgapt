#!/usr/bin/env bash
ls | grep -v runTestSuite | xargs -I{} bash {}
