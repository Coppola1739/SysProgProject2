#!/bin/bash

file_id="1Wuko3rkpL9TtOXTSIVmZ3tFHYFQs2sxf"
export_url="https://drive.google.com/uc?export=download&id=${file_id}"

curl -L -o log_file.txt "$export_url"

input_file="log_file.txt"
output_file="audit_rpt.txt"

grep -n "173.255.170.15" "$input_file" | sed 's/^\([0-9]*\):\(.*\)/Line: \1, bad IP found \2/' > "$output_file"
grep -n -E "UNION|SELECT|' OR 1=1|DROP TABLE" "$input_file" | sed 's/^\([0-9]*\):\(.*\)/Line: \1, SQL Injection attempt found \2/' >> "$output_file"

zip -j processed_log.zip "$input_file" "$output_file"

