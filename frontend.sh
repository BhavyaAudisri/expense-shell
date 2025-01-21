#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}
echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y  &>>$LOG_FILE_NAME
    validate $? " installing nginx " &>>$LOG_FILE_NAME

systemctl enable nginx &>>$LOG_FILE_NAME
    validate $? " enabling nginx " &>>$LOG_FILE_NAME

systemctl start nginx &>>$LOG_FILE_NAME
    validate $? " starting nginx " &>>$LOG_FILE_NAME

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
    validate $? " downloading the code " &>>$LOG_FILE_NAME

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
    validate $? " unzip frontend " &>>$LOG_FILE_NAME

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf 

systemctl restart nginx &>>$LOG_FILE_NAME
    validate $? " restart the nginx server " &>>$LOG_FILE_NAME