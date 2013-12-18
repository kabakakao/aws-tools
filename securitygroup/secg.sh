#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
echo $SCRIPT_DIR

SECG_NAME="opp-batch"
SECG_DESC="sg for opp batch"
VPC_ID="vpc-6fb68607"

if [ $(aws ec2 describe-security-groups --filters Name=group-name,Values=$SECG_NAME | jq '.SecurityGroups | length') == 1 ]
then
  echo "Error: Already created Security Group(${SECG_NAME})" 1>&2
  exit 1
fi

echo "# Create a new Security Group ${SG_NAME} to VPC(${VPC_ID})"
seg_g_result_array=(`aws ec2 create-security-group --group-name ${SECG_NAME} --description "${SECG_DESC}" --vpc-id ${VPC_ID} | jq '.return,.GroupId' -r`)

SECG_RETURN=${seg_g_result_array[0]}
SECG_ID=${seg_g_result_array[1]}
if [ "${SECG_RETURN}" = "false" ]
then
 echo "Error: aws ec2 --group-name ${SECG_NAME} --description "${SECG_DESC}" --vpc-id ${VPC_ID}"
 exit 1
fi

echo "# Add rules"
aws ec2 authorize-security-group-ingress --group-id ${SECG_ID} --ip-permissions "file://${SCRIPT_DIR}/ippermissions.json"

echo "# The Security Group"
aws ec2 describe-security-groups --filters Name=group-name,Values=${SECG_NAME} --query "SecurityGroups[0]"

echo "# You can remove the Security Group by the following command."
echo "aws ec2 delete-security-group --group-id ${SECG_ID}"