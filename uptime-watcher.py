#!/usr/bin/python

from subprocess import call
import argparse
import random
import os

if os.getuid() != 0:
    raise SystemExit('Expecting root privileges. Root privileges needed for GPIO pin usage.')

parser = argparse.ArgumentParser(description = 'Get uptimes and control light accordingly')
parser.add_argument('--verbose', '-v', action = 'store_true')
args = parser.parse_args()

# Random states for all three lights
red_light_on    = random.choice([True, False])
yellow_light_on = random.choice([True, False])
green_light_on  = random.choice([True, False])

# Print out things if verbose
if args.verbose:
    print("Red light on:    " + red_light_on)
    print("Yellow light on: " + yellow_light_on)
    print("Green light on:  " + green_light_on)

# Set the light states
if red_light_on:
    call(['light-control', 'red', 'on'])
else:
    call(['light-control', 'red', 'off'])

if yellow_light_on:
    call(['light-control', 'yellow', 'on'])
else:
    call(['light-control', 'yellow', 'off'])

if green_light_on:
    call(['light-control', 'green', 'on'])
else:
    call(['light-control', 'green', 'off'])
