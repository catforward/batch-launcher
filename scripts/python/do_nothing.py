#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, sys

print("my id is %s. wrote by %s." % \
(sys.argv[1], os.getenv("PROC_TYPE", default = "unknown")))

sys.exit(0)