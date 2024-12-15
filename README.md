# Terraform-AWS
Hello I am Mustafa Karabayir, the creator of this project.

Here are some points you have to do manually.

after doing a terraform apply:
    This is to upload a file to the API and get the file on the Apache Webserver.
    -run the command:
            curl -X POST -H "filename: <File Name .extention>" -d "<Message you want to insert>" <URL from the output>
        example:
            curl -X POST -H "filename: ba.txt" -d "Mustafa says hallo" https://dxp8dr8o1c.execute-api.eu-west-1.amazonaws.com/production/upload
        
For mounting instances to the EFS, yu have to connect with the instance.
    -run the command:
            (you copy the command on the EFS attach and past that in the instance and change the mount location to /mnt/efs)
        example:
            sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.0.1.160:/ /mnt/efs

To push it on github you have to navigate to the location of your terraform project and run the following commands
    -run the command:
        git add .
        git commit -m "<a random message>"
        git push

that all should work