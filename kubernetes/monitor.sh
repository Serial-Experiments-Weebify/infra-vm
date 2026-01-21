#!/bin/bash
while true; do
  curl -s -o /dev/null -w "%{http_code}\n" https://devops.weebify.tv/
done