## 🚀 How to Use This Project

### Prerequisites
- **AWS Account**: AWS Educate account or regular AWS account with appropriate permissions
- **AWS CLI**: Installed and configured with your credentials
- **Terraform**: Either use the included `terraform.exe` or install Terraform locally
- **Windows Environment**: The project includes a Windows batch manager for easy operation

#### Option 1: Using the Terraform Manager (Recommended)
The project includes a convenient Windows batch file that handles all Terraform operations:

1. **Navigate to the project directory:**
   ```cmd
   cd "....."
   ```
2. **Run the Terraform Manager:**
   ```cmd
   terraform-manager.bat
   ```
3. **Follow the interactive menu:**
   - Choose `[1] Update AWS Credentials` to configure your AWS access
   - Choose `[2] Initialize Terraform` to set up the working directory
   - Choose `[3] Validate Configuration` to check syntax
   - Choose `[4] Plan Deployment` to preview changes
   - Choose `[5] Apply Infrastructure` to deploy resources

#### Option 2: Manual Terraform Commands
If you prefer using Terraform directly:

1. **Initialize Terraform:**
   ```cmd
   terraform init
   ```

2. **Validate Configuration:**
   ```cmd
   terraform validate
   ```

3. **Plan Deployment:**
   ```cmd
   terraform plan -var-file="aws-educate.terraform.tfvars"
   ```

4. **Apply Infrastructure:**
   ```cmd
   terraform apply -var-file="aws-educate.terraform.tfvars"
   ```

### Configuration Options

#### Environment Variables
The project uses `aws-educate.terraform.tfvars` for configuration. Key parameters you can modify:

```hcl
# Environment name
env = "educate"

# AWS Region
region = "us-east-1"

# VPC CIDR block
vpc_conf = {
  cidr = "10.0.0.0/16"
}

# Instance type (t2.micro for free tier)
instance_type = "t2.micro"

# Public and private subnet configurations
public_subnets = {
  "us-east-1a" = "10.0.1.0/24"
  "us-east-1b" = "10.0.2.0/24"
}
```

#### Customization
- **Change Instance Types**: Modify `instance_type` in the tfvars file
- **Adjust Scaling**: Edit auto-scaling parameters in the configuration files
- **Security Rules**: Modify security group rules in the tfvars file
- **Database Settings**: Adjust RDS configuration in the relevant .tf files

### Monitoring and Maintenance

#### Using the Manager Interface
The `terraform-manager.bat` provides several monitoring options:
- `[6] Show Current State` - View current infrastructure state
- `[7] View Outputs` - Display important resource information (URLs, IPs)
- `[8] Monitor Resources` - Real-time resource monitoring
- `[9] Quick Health Check` - Verify infrastructure health

#### Manual Monitoring
```cmd
# View current state
terraform show

# List all resources
terraform state list

# Get specific outputs
terraform output
```

### Cleanup and Destruction

⚠️ **Important**: Always destroy resources when done to avoid unnecessary charges!

#### Using the Manager
- Choose `[D] Destroy Infrastructure` from the main menu
- Follow the prompts to confirm destruction

#### Manual Cleanup
```cmd
terraform destroy -var-file="aws-educate.terraform.tfvars"
```