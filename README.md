# IAM Web Services Setup Guide

This guide provides step-by-step instructions for setting up IAM web services using SAS. Follow these instructions to establish a secure and efficient IAM environment.

## 1. Directory Setup

Create the necessary directories and subdirectories in the specified hierarchical order for IAM web services.

## 2. Library Registration

Create and register any RDBMS library dedicated to IAM-related tables to ensure seamless data access. 

Eg. In Code IAM library is created on Oracle DB.

## 3. IAM Tables Creation

Utilize the file "IAM_TABLES_DDL'S.txt" to create IAM tables into the assigned IAM library.

## 4. Stored Processes

Import stored processes using the provided links in the document. Place these stored processes under the repository using SAS Management Console, SAS DI Studio.

## 5. Parameter Configuration

Ensure that all parameters for the stored processes are configured according to the screenshots provided in the document.

## 6. Web Service Deployment

Deploy the created stored processes as web services through SAS Management Console or SAS DI Studio to enable efficient access to IAM functionalities.

## 7. WebAnon Setup

Follow the steps outlined in the following URL [WebAnon Setup Guide](https://support.sas.com/kb/52/218.html) to enable WebAnon for the web services.


