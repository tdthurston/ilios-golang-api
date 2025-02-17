package handlers

import (
	"encoding/json"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

func VpcResponse() string {
	sess := session.Must(session.NewSession())
	sess.Config.Region = aws.String("us-east-1")
	svc := ec2.New(sess)
	input := &ec2.DescribeVpcsInput{}

	result, err := svc.DescribeVpcs(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				log.Println(aerr.Error())
			}
		} else {
			log.Println(err.Error())
		}
		return "Unable to retrieve VPC data"
	}

	// Extract VPC Data
	vpcs := []map[string]string{}
	for _, vpc := range result.Vpcs {
		vpcData := map[string]string{
			"id": *vpc.VpcId,
		}
		vpcs = append(vpcs, vpcData)
	}

	// Convert the VPC data into JSON format
	vpcsJSON, err := json.Marshal(map[string]interface{}{"vpcs": vpcs})
	if err != nil {
		log.Println("Error marshaling VPCs to JSON:", err)
		return `{"error": "Error processing VPC data"}`
	}

	return string(vpcsJSON)

}
