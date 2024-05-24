#!/bin/bash
#
# delete the geolab database
#

psql -h localhost -U postgres -f sql/drop-geolab.psql -d postgres -W

