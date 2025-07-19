# 🌐 Complete AWS Resource Inventory

This repository documents the full architecture of an AWS infrastructure stack designed for a scalable, secure, and production-ready web application.

## 👥 Contributors

This project was developed as part of a **Cloud Computing** academic initiative by:

| Name | Matriculation Number |
|------|---------------------|
| **Karan Patel** | 1563308 |
| **Ranesh Nair Anil** | 1563267 |
| **Hammad Asif** | 1538490 |
| **Allan Valim Ribeiro da Fonseca** | 350105 |

## 📦 Overview

The stack includes compute resources, load balancing, VPC networking, database, file storage, WAF protection, monitoring, and utility services—all orchestrated to support high availability and fault tolerance.

---

## 🖥️ EC2 & Compute (7 Resources)

| Resource                | Description                                           | Technical Purpose |
| ----------------------- | ----------------------------------------------------- | ----------------- |
| 3 EC2 Instances         | Auto Scaling Group-managed compute nodes on `t2.micro` | **Horizontal scaling compute layer** - Provides redundant application hosting with automatic instance replacement |
| 1 Launch Template       | Immutable infrastructure template with AMI, security groups, and user data | **Infrastructure as Code** - Ensures consistent instance provisioning and configuration drift prevention |
| 1 Auto Scaling Group    | Dynamic capacity management (min: 2, max: 3, desired: 3) across AZs | **High Availability & Elasticity** - Maintains service availability and handles variable load patterns |
| 2 Auto Scaling Policies | CloudWatch-triggered scaling policies (CPU >20% up, <10% down) | **Reactive Scaling** - Implements auto-scaling based on performance metrics with configurable thresholds |

---

## 🔄 Load Balancing (3 Resources)

| Resource                          | Description                             | Technical Purpose |
| --------------------------------- | --------------------------------------- | ----------------- |
| 1 Application Load Balancer (ALB) | Layer 7 HTTP/HTTPS load balancer with path-based routing | **Traffic Distribution & SSL Termination** - Provides advanced routing capabilities and protocol handling |
| 1 Target Group                    | Health check and routing configuration for backend instances | **Service Discovery & Health Management** - Maintains registry of healthy targets with configurable health checks |
| 1 Listener                        | Port 80 HTTP listener with forwarding rules to target group | **Protocol Handling** - Defines how incoming connections are processed and routed to backend services |

---

## 🌐 VPC & Networking (15 Resources)

| Resource           | Description                                        | Technical Purpose |
| ------------------ | -------------------------------------------------- | ----------------- |
| 1 VPC              | Isolated virtual network (`10.0.0.0/16`) with DNS resolution enabled | **Network Isolation** - Provides software-defined networking with complete control over IP addressing |
| 4 Subnets          | Multi-AZ subnet architecture: 2 public + 2 private subnets | **Network Segmentation** - Implements DMZ architecture separating public-facing and backend resources |
| 1 Internet Gateway | Horizontally scaled VPC internet access point | **Internet Connectivity** - Provides bidirectional internet connectivity for public subnet resources |
| 2 Elastic IPs      | Static IPv4 addresses for NAT gateway high availability | **Consistent Egress IPs** - Ensures predictable outbound IP addresses for whitelisting and logging |
| 2 NAT Gateways     | Managed NAT service for outbound internet connectivity from private subnets | **Secure Egress** - Enables internet access for private resources without inbound exposure |
| 3 Route Tables     | Custom routing logic: 1 public (IGW) + 2 private (NAT) route tables | **Traffic Engineering** - Controls packet forwarding decisions based on destination CIDR blocks |
| 4 Associations     | Subnet-to-route-table bindings defining traffic flow patterns | **Routing Implementation** - Enforces network segmentation through explicit subnet routing policies |

---

## 🔒 Security Groups (4 Resources)

| Security Group | Access Rules                        | Technical Purpose |
| -------------- | ----------------------------------- | ----------------- |
| ALB SG         | Ingress: HTTP/80 from 0.0.0.0/0, Egress: All protocols | **Edge Security** - Implements stateful firewall rules for internet-facing load balancer |
| EC2 SG         | Ingress: HTTP/80 from ALB SG + SSH/22 from 0.0.0.0/0 | **Compute Security** - Restricts application server access to necessary protocols and sources |
| RDS SG         | Ingress: MySQL/3306 from EC2 SG only | **Database Security** - Implements database-tier access control with principle of least privilege |
| EFS SG         | Ingress: NFS/2049 from EC2 SG only | **Storage Security** - Controls network file system access through security group referencing |

> **Security Groups implement stateful packet filtering** with automatic return traffic allowance and security group cross-referencing for scalable access control.

---

## 🗄️ Database (3 Resources)

| Resource             | Description                                        | Technical Purpose |
| -------------------- | -------------------------------------------------- | ----------------- |
| 1 RDS MySQL Instance | Managed MySQL 8.0 database on `db.t3.micro` with Multi-AZ disabled | **Persistent Data Layer** - Provides ACID-compliant relational database with automated maintenance |
| 1 DB Subnet Group    | Cross-AZ database subnet group ensuring high availability | **Database Placement** - Defines subnet placement for RDS Multi-AZ deployments and failover |
| 1 SSM Parameter      | Encrypted database password stored in AWS Systems Manager | **Secrets Management** - Centralized, encrypted credential storage with access logging |

> **RDS abstracts database administration** including automated backups, patch management, and monitoring while providing configurable Multi-AZ deployments.

---

## 📁 File Storage (3 Resources)

| Resource          | Description                     | Technical Purpose |
| ----------------- | ------------------------------- | ----------------- |
| 1 EFS File System | POSIX-compliant NFS v4.1 distributed file system | **Shared Persistent Storage** - Provides concurrent, scalable file system access across multiple compute instances |
| 2 Mount Targets   | Multi-AZ EFS network interfaces in each private subnet | **Network Accessibility** - Ensures high availability file system access with cross-AZ redundancy |

> **EFS provides elastic, serverless file storage** with automatic scaling, encryption at rest/transit, and POSIX compliance for Linux-based workloads.

---

## 🛡️ WAF (3 Resources)

| Resource          | Description                                | Technical Purpose |
| ----------------- | ------------------------------------------ | ----------------- |
| 1 WAF IP Set      | Regional IP blacklist with CIDR block `162.120.187.65/32` | **Network-based Threat Blocking** - Implements IP-based access control at the application layer |
| 1 Web ACL         | Layer 7 firewall with custom security rules and rate limiting | **Application Layer Security** - Provides SQL injection, XSS, and DDoS protection with customizable rule sets |
| 1 WAF Association | Binds Web ACL to Application Load Balancer | **Policy Enforcement** - Applies WAF rules to ALB traffic before reaching target groups |

> **WAFv2 provides advanced application security** with managed rule groups, rate-based rules, and geo-blocking capabilities at the edge.

---

## 📊 Monitoring (2 Resources)

| Resource            | Description                            | Technical Purpose |
| ------------------- | -------------------------------------- | ----------------- |
| 2 CloudWatch Alarms | CPU utilization thresholds: >20% scale-out, <10% scale-in with 2-minute evaluation periods | **Metrics-based Auto Scaling** - Implements reactive scaling policies based on CloudWatch metrics and configurable thresholds |

> **CloudWatch integration enables proactive infrastructure management** through metric collection, threshold-based alerting, and automated response mechanisms.

---

## 🔧 Utility Resources (2 Resources)

| Resource          | Description                       | Technical Purpose |
| ----------------- | --------------------------------- | ----------------- |
| 1 Random Password | Cryptographically secure password generation for RDS authentication | **Secure Credential Generation** - Provides entropy-based password creation with configurable complexity |
| 1 Random ID       | Hexadecimal identifier suffix for resource naming collision avoidance | **Resource Uniqueness** - Ensures globally unique resource names across multiple deployments |

> **Infrastructure automation utilities** that enhance security and deployment reliability through programmatic resource generation.

---

## 📈 Resource Summary

| Category               | Count |
| ---------------------- | ----- |
| Total Resources        | ~41   |
| EC2 Instances          | 3     |
| Networking Components  | 15    |
| Security Groups        | 4     |
| Load Balancer Elements | 3     |
| Database Components    | 3     |
| Storage Components     | 3     |
| WAF Components         | 3     |
| Monitoring             | 2     |
| Utility Resources      | 2     |

---

## 🔄 How Everything Works Together

### **Request Processing Flow:**

1. **Client Request** → HTTP request initiated to ALB endpoint
2. **WAF Inspection** → Layer 7 firewall evaluates request against ACL rules
3. **Load Balancing** → ALB performs health-check-based target selection
4. **Application Processing** → EC2 instance processes request with potential database/storage I/O
5. **Data Layer Access** → RDS connection pooling and EFS file system operations as needed
6. **Response Path** → Application response traverses back through ALB to client

### **Security Architecture (Defense in Depth):**
- **Network Isolation:** VPC with private/public subnet segmentation
- **Transport Security:** Security Group stateful packet filtering
- **Application Security:** WAFv2 with IP blocking and rate limiting  
- **Access Control:** IAM roles and security group cross-referencing
- **Data Protection:** SSM Parameter Store encryption and RDS security groups

### **High Availability Design:**
- **Multi-AZ Deployment:** Resources distributed across availability zones
- **Auto Scaling:** Horizontal scaling based on CloudWatch metrics
- **Load Distribution:** ALB with health checks and connection draining
- **Data Persistence:** EFS for shared storage, RDS for transactional data
- **Fault Tolerance:** Auto Scaling Group instance replacement and ALB target deregistration

---

## ✅ Architecture Principles

* **🔄 Horizontal Scalability** - Auto Scaling Groups with CloudWatch-driven policies
* **🛡️ Multi-layered Security** - Network segmentation, WAF, and security group policies  
* **🌐 High Availability** - Multi-AZ deployment with automated failover capabilities
* **📊 Shared State Management** - EFS for distributed file storage and RDS for transactional data
* **🔍 Observability** - CloudWatch metrics integration for performance monitoring
* **🏗️ Infrastructure as Code** - Declarative Terraform configuration with state management

---

## 📝 Implementation Notes

* Architecture implements a standard three-tier web application pattern with presentation (ALB), application (EC2), and data layers (RDS/EFS)
* Network design follows AWS Well-Architected Framework security pillar with private subnet isolation
* Auto Scaling policies configured for cost optimization while maintaining performance SLAs
* Regional deployment in `us-east-1` with cross-AZ redundancy for fault tolerance
