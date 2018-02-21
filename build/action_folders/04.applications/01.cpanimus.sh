#!/bin/bash

source "${TOOLS}/04.downloads/01.CPANIMUS"
cd /tmp
cat "${CPANIMUS['file']}" | perl - App::cpanminus
