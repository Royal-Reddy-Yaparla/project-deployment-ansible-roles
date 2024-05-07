#!/bin/bash

#############################################################################
# Author: ROYAL REDDY
# Date: 14-04
# Version: V2
# Purpose: Automate the process of creating EC2 instances and Route53 records
#############################################################################

INSTANCE=""
PRIVATE_IP=""
DOMAIN_NAME="royalreddy.co.in"
HOST_ID="Z07439021R4NQF6C9ULT9"


INSTANCE=("cart" "catalogue" "mongodb" "mysql" "redis" "dispatch" "rabbitmq" "web" "user" "payment" "shipping")
#  
for i in "${INSTANCE[@]}"
do
    echo "Name: $i"
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ];then 
        INSTANCE="t3.medium"
    else
        INSTANCE="t2.micro"
    fi
    PRIVATE_IP=$(aws ec2 run-instances --image-id ami-0f3c7d07486cad139  --instance-type $INSTANCE \
--key-name nv_keypair --security-group-ids sg-0ad71420a0b2e2f78 --subnet-id subnet-08a8ac34932166a4b \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text
)
echo "$i:$PRIVATE_IP"
# create R53 record, need to make sure already created 
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOST_ID \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
    "Action"              : "UPSERT"
    ,"ResourceRecordSet"  : {
        "Name"              :  "'$i'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$PRIVATE_IP'"
        }]
      }
    }]
  }
  '
done 