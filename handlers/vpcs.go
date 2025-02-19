package handlers

import (
	"encoding/json"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

func VpcInfo() string {
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
		vpcName := "N/A"
		for _, tag := range vpc.Tags {
			if *tag.Key == "Name" {
				vpcName = *tag.Value
				break
			}
		}

		vpcData := map[string]string{

			"name":  vpcName,
			"id":    *vpc.VpcId,
			"cidr":  *vpc.CidrBlock,
			"state": *vpc.State,
			
		}
		vpcs = append(vpcs, vpcData)
	}

	// Convert the VPC data into JSON format
	vpcsJSON, err := json.MarshalIndent(map[string]interface{}{"VPCs": vpcs}, "", "    ")
	if err != nil {
		log.Println("Error marshaling VPCs to JSON:", err)
		return `{"error": "Error processing VPC data"}`
	}

	return string(vpcsJSON)

}
