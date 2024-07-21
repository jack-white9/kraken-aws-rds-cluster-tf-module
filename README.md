# AWS RDS Cluster Module

This module deploys an RDS cluster with two instances – a read instance and a write instance. The module supports a range of inputs with sensible defaults [listed below](#inputs), but the following inputs are required:

- `vpc_id`: The ID of the VPC the DB Cluster will be deployed into
- `subnet_ids`: Subnet IDs in which the database instances should be created in
- `security_groups`: A list of security group IDs allowed access to the DB cluster.

To deploy an example cluster that comes with a working networking configuration out-of-the-box, see `examples/aurora-postgresql`.

## Usage

Basic usage:

```hcl
module "aws_rds_cluster" {
  source = "../../"

  vpc_id          = "vpc-12345678"
  subnet_ids      = ["subnet-12345678"]
  security_groups = ["sg-12345678"]
}
```

Usage with further customisation:

```hcl
module "aws_rds_cluster" {
  source = "aws_rds_cluster"

  # cluster properties
  cluster_identifier       = "kraken-aurora-cluster"
  engine                   = "aurora-postgresql"
  availability_zones       = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  database_name            = "kraken_database"
  master_username          = "foo"
  master_password          = "foobar1234"
  snapshot_before_deletion = true

  # cluster networking properties
  vpc_id          = "vpc-12345678"
  security_groups = ["sg-12345678"]
  security_group_rules = [{
    type      = "ingress",
    from_port = 5432,
    to_port   = 5432,
    protocol  = "tcp",
    self      = true
  }]
  subnet_ids = ["subnet-12345678"]

  # instance properties
  read_instance_class  = "db.r6gd.xlarge"
  write_instance_class = "db.r6g.large"
}
```

## Conditional Creation

The following value is provided to toggle creation of the associated resources as desired:

```hcl
# This RDS cluster will not be created
module "cluster" {
  source  = "aws_rds_cluster"

  # Disable creation of cluster and all resources
  create = false
  # ...
}
```

## Examples

- [Aurora PostgreSQL](./examples/aurora-postgresql/): A PostgreSQL cluster with a single read instance and a single write instance.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.48.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.58.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_instance.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs in which the database instances should be created in. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to deploy the cluster into. | `string` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of EC2 Availability Zones for the cluster storage where cluster instances can be created. 3 AZs recommended. | `list(string)` | <pre>[<br>  "ap-southeast-2a",<br>  "ap-southeast-2b",<br>  "ap-southeast-2c"<br>]</pre> | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Days to retain backups for. | `number` | `30` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The cluster identifier. If omitted, Terraform will assign a random, unique identifier. | `string` | `"kraken-aurora-cluster"` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether the cluster should be created. | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for the database created on cluster creation. | `string` | `"kraken_database"` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Name of the database engine to be used for the cluster. | `string` | `"aurora-postgresql"` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Whether to allow RDS to manage the master user/password in Secrets Manager. | `bool` | `true` | no |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | Password for the master DB user. | `string` | `null` | no |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | Username for the master DB user. | `string` | `null` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | Daily time range during which automated backups are created. | `string` | `"00:00-02:00"` | no |
| <a name="input_read_instance_class"></a> [read\_instance\_class](#input\_read\_instance\_class) | Instance class for database read instance. | `string` | `"db.r6gd.xlarge"` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | List of security group rules to attach to the cluster. | <pre>list(object({<br>    type                     = string,<br>    from_port                = string,<br>    to_port                  = string,<br>    protocol                 = string,<br>    description              = optional(string),<br>    prefix_list_ids          = optional(list(string)),<br>    cidr_blocks              = optional(list(string)),<br>    ipv6_cidr_blocks         = optional(list(string)),<br>    self                     = optional(bool),<br>    source_security_group_id = optional(string)<br>    }<br>  ))</pre> | <pre>[<br>  {<br>    "from_port": 5432,<br>    "protocol": "tcp",<br>    "self": true,<br>    "to_port": 5432,<br>    "type": "ingress"<br>  }<br>]</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of VPC security groups to associate with the cluster. | `list(string)` | `[]` | no |
| <a name="input_snapshot_before_deletion"></a> [snapshot\_before\_deletion](#input\_snapshot\_before\_deletion) | Whether to perform a final snapshot before deletion. | `bool` | `true` | no |
| <a name="input_write_instance_class"></a> [write\_instance\_class](#input\_write\_instance\_class) | Instance class for database write instance. | `string` | `"db.r6g.large"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The DNS address of the cluster. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | The DNS address of the read replica. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group attached to the RDS cluster. |
<!-- END_TF_DOCS -->
