#!/bin/bash
dnf update -y
dnf install -y python3 python3-pip

cd /home/ec2-user
git clone https://github.com/EdisonLim17/iam-policy-generator.git
cd iam-policy-generator/app

pip3 install --upgrade pip
pip3 install -r requirements.txt

nohup uvicorn main:app --host 0.0.0.0 --port 80 > app.log 2>&1 &