aws ec2 create-key-pair --key-name rohan4 --query KeyMaterial > finalkey.pem --output text > rohan4.pem

set key="rohan4.pem"

aws ec2 create-security-group --group-name rohan --description "aws cli task security group" --output text > security.text

aws ec2 authorize-security-group-ingress  --group-name rohan --cidr 0.0.0.0/0 --protocol all

timeout 2

set /p variable1=<security.text

aws ec2 run-instances --image-id ami-03cfb5e1fb4fac428 --instance-type t2.micro --key-name rohan4 --subnet-id subnet-8e2124e6 --security-group-ids %variable1% --query Instances[].InstanceId --output text > instanceid.text

set /p variable=<instanceid.text

timeout 30

aws ec2 describe-instances --query Reservations[-1].Instances[].[PublicDnsName] --output text > name.text

set /p name1=<name.text

aws ec2 create-volume --availability-zone ap-south-1a --size 1 --query VolumeId --output text >pop.text

timeout 10

aws ec2 attach-volume --device /dev/sdb --instance-id %variable% --volume-id file://pop.text

ssh -i %key% ec2-user@%name1% sudo yum install httpd -y

ssh -i %key% ec2-user@%name1% sudo fdisk /dev/xvdb

ssh -i %key% ec2-user@%name1% sudo mkfs.ext4 /dev/xvdb1

ssh -i %key% ec2-user@%name1% sudo mount /dev/xvdb1 /var/www/html


aws s3api create-bucket --bucket rohan1231231 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1

set image=vimal_sir.jpeg
 
aws s3api put-object --acl public-read-write --bucket rohan1231231 --key %image% --body %image%

set s3="https://rohan1231231.s3.ap-south-1.amazonaws.com/%image%"

set domain=rohan1231231.s3.ap-south-1.amazonaws.com

aws cloudfront create-distribution --origin-domain-name %domain% --query Distribution.DomainName --output text > cloudfront.text

timeout 60

set /p cloudfront=<cloudfront.text

set url="<body><center><img src=https://%cloudfront%/%image% alt="dont loaded"></center></body>"

echo %url% > url.html

scp -i %key% -r url.html ec2-user@%name1%:~

ssh -i %key% ec2-user@%name1% sudo sed 's/\"//g' url.html > index.html

ssh -i %key% ec2-user@%name1% sudo cp index.html /var/www/html/

ssh -i %key% ec2-user@%name1% sudo service httpd start



