@echo off
setlocal enabledelayedexpansion
title AWS Terraform Manager - AWS Educate Edition
color 0F

:: Set the current directory to script location
cd /d "%~dp0"

:MAIN_MENU
cls
echo.
echo ===============================================
echo    AWS Terraform Infrastructure Manager
echo              AWS Educate Edition
echo ===============================================
echo.
echo Current Directory: %CD%
echo Terraform Config: aws-educate.terraform.tfvars
echo.
echo [1] Update AWS Credentials
echo [2] Initialize Terraform
echo [3] Validate Configuration
echo [4] Plan Deployment
echo [5] Apply Infrastructure
echo [6] Show Current State
echo [7] View Outputs
echo [8] Monitor Resources
echo [9] Quick Health Check
echo [D] Destroy Infrastructure
echo [0] Exit
echo.
echo ===============================================
set /p choice="Please select an option (0-9, D): "

if "%choice%"=="1" goto UPDATE_CREDS
if "%choice%"=="2" goto INIT
if "%choice%"=="3" goto VALIDATE
if "%choice%"=="4" goto PLAN
if "%choice%"=="5" goto APPLY
if "%choice%"=="6" goto SHOW
if "%choice%"=="7" goto OUTPUT
if "%choice%"=="8" goto MONITOR
if "%choice%"=="9" goto HEALTH_CHECK
if /i "%choice%"=="D" goto DESTROY
if "%choice%"=="0" goto EXIT
goto INVALID_CHOICE

:UPDATE_CREDS
cls
echo ===============================================
echo         Update AWS Credentials
echo ===============================================
echo.
echo AWS Educate accounts use temporary session tokens.
echo Please enter your credentials:
echo.

:: Get Access Key ID (visible)
set /p AWS_ACCESS_KEY="AWS Access Key ID: "

:: Get Secret Access Key (hidden)
echo.
echo AWS Secret Access Key: 
powershell -Command "$secure = Read-Host -AsSecureString; $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure); $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr); [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr); Write-Output $plain" > temp_secret.txt
set /p AWS_SECRET_KEY=<temp_secret.txt
del temp_secret.txt >nul 2>&1

:: Get Session Token (hidden)
echo.
echo AWS Session Token:
powershell -Command "$secure = Read-Host -AsSecureString; $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure); $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr); [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr); Write-Output $plain" > temp_token.txt
set /p AWS_SESSION_TOKEN=<temp_token.txt
del temp_token.txt >nul 2>&1

echo.
echo Setting environment variables...
set AWS_ACCESS_KEY_ID=%AWS_ACCESS_KEY%
set AWS_SECRET_ACCESS_KEY=%AWS_SECRET_KEY%
set AWS_SESSION_TOKEN=%AWS_SESSION_TOKEN%
set AWS_DEFAULT_REGION=us-east-1

echo.
echo Testing credentials...
aws sts get-caller-identity >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Credentials set successfully!
    echo.
    aws sts get-caller-identity
) else (
    echo ✗ Failed to authenticate with provided credentials.
    echo Please check your credentials and try again.
)
echo.
pause
goto MAIN_MENU

:INIT
cls
echo ===============================================
echo           Initializing Terraform
echo ===============================================
echo.
echo This will download required providers and initialize the backend...
echo.
pause
terraform init
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Terraform initialized successfully!
) else (
    echo.
    echo ✗ Terraform initialization failed!
)
echo.
pause
goto MAIN_MENU

:VALIDATE
cls
echo ===============================================
echo         Validating Configuration
echo ===============================================
echo.
terraform validate
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Configuration is valid!
) else (
    echo.
    echo ✗ Configuration validation failed!
)
echo.
pause
goto MAIN_MENU

:PLAN
cls
echo ===============================================
echo          Planning Deployment
echo ===============================================
echo.
echo This will show what resources will be created...
echo.
terraform plan -var-file="aws-educate.terraform.tfvars"
echo.
echo Plan completed. Review the changes above.
echo.
pause
goto MAIN_MENU

:APPLY
cls
echo ===============================================
echo        Applying Infrastructure
echo ===============================================
echo.
echo WARNING: This will create AWS resources that may incur charges!
echo Make sure you understand the costs involved.
echo.
set /p confirm="Are you sure you want to proceed? (y/N): "
if /i not "%confirm%"=="y" goto MAIN_MENU

echo.
echo Applying Terraform configuration...
terraform apply -var-file="aws-educate.terraform.tfvars"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Infrastructure deployed successfully!
    echo.
    echo Showing outputs:
    terraform output
) else (
    echo.
    echo ✗ Infrastructure deployment failed!
)
echo.
pause
goto MAIN_MENU

:SHOW
cls
echo ===============================================
echo         Current Infrastructure State
echo ===============================================
echo.
terraform show
echo.
pause
goto MAIN_MENU

:OUTPUT
cls
echo ===============================================
echo           Infrastructure Outputs
echo ===============================================
echo.
terraform output
echo.
echo Key Information:
echo - ALB DNS Name: Use this to access your application
echo - Database Endpoint: For application database connection
echo - EFS File System ID: For shared storage
echo.
echo ===== WEB ACCESS URLS =====
for /f "delims=" %%i in ('terraform output -raw alb_dns_name 2^>nul') do (
    echo.
    echo 🌐 Main Application: http://%%i/
    echo ❤️  Health Check: http://%%i/health
    echo.
    echo To open in browser: start http://%%i/
    goto OUTPUT_END
)
echo ⚠️  ALB DNS name not found. Make sure infrastructure is deployed.
:OUTPUT_END
echo ============================
echo.
pause
goto MAIN_MENU

:MONITOR
cls
echo ===============================================
echo          AWS Resources Monitor
echo ===============================================
echo.
echo Checking AWS CLI availability...
aws --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo AWS CLI not found. Please install AWS CLI to use this feature.
    goto MONITOR_END
)

echo.
echo [1] Current AWS Identity
echo [2] EC2 Instances Status
echo [3] Load Balancer Status
echo [4] RDS Database Status
echo [5] Auto Scaling Group
echo [6] Terraform State List
echo [7] Return to Main Menu
echo.
set /p monChoice="Select monitoring option (1-7): "

if "%monChoice%"=="1" (
    echo.
    echo Current AWS Profile/Region:
    aws sts get-caller-identity
)
if "%monChoice%"=="2" (
    echo.
    echo EC2 Instances:
    aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicDnsName]" --output table
)
if "%monChoice%"=="3" (
    echo.
    echo Load Balancers:
    aws elbv2 describe-load-balancers --query "LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]" --output table
)
if "%monChoice%"=="4" (
    echo.
    echo RDS Instances:
    aws rds describe-db-instances --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]" --output table
)
if "%monChoice%"=="5" (
    echo.
    echo Auto Scaling Group Status:
    aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[*].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize]" --output table
)
if "%monChoice%"=="6" (
    echo.
    echo Current Terraform Resources:
    terraform state list
)
if "%monChoice%"=="7" goto MAIN_MENU

:MONITOR_END
echo.
pause
goto MAIN_MENU

:DESTROY
cls
echo ===============================================
echo        Destroy Infrastructure
echo ===============================================
echo.
echo ⚠️  WARNING: This will PERMANENTLY DELETE all AWS resources!
echo    - All EC2 instances
echo    - Load balancer
echo    - RDS database
echo    - VPC and networking
echo    - All data will be lost!
echo.
set /p confirm="Are you sure you want to destroy? (y/N): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled.
    pause
    goto MAIN_MENU
)

echo.
echo Destroying infrastructure...
terraform destroy -var-file="aws-educate.terraform.tfvars"
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Infrastructure destroyed successfully!
    echo All AWS resources have been deleted.
) else (
    echo.
    echo ✗ Infrastructure destruction failed!
    echo Some resources may still exist. Check AWS console.
)
echo.
pause
goto MAIN_MENU

:HEALTH_CHECK
cls
echo ===============================================
echo           Quick Health Check
echo ===============================================
echo.
echo Checking infrastructure health...
for /f "delims=" %%i in ('terraform output -raw alb_dns_name 2^>nul') do (
    echo ✓ ALB DNS: %%i
    echo.
    echo Testing health endpoint...
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://%%i/health' -TimeoutSec 10; Write-Host '✓ Health check PASSED!' -ForegroundColor Green; Write-Host 'Status:' $response.StatusCode } catch { Write-Host '✗ Health check FAILED:' $_.Exception.Message -ForegroundColor Red }"
    echo.
    echo To open application: start http://%%i/
    goto HEALTH_END
)
echo ✗ Infrastructure not deployed or ALB not found.
echo Please deploy infrastructure first (option 5).
:HEALTH_END
echo.
pause
goto MAIN_MENU

:INVALID_CHOICE
cls
echo.
echo Invalid choice. Please select a valid option.
echo.
pause
goto MAIN_MENU

:EXIT
cls
echo.
echo Thank you for using AWS Terraform Manager!
echo Remember to destroy resources when not needed to avoid charges.
echo.
pause
exit /b 0