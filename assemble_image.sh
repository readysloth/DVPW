#!/bin/sh

cat baked_image/* | xz -d > disk.img
