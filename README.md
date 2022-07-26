
## quickstart-aws-utility-meter-data-generator—Quick Start
To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo. 
To submit code for this Quick Start, see the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/).

## Overview
This Quick Start deploys a completely serverless solution on the AWS Cloud and simulates the generation of readings by utility meters and inserting into an Amazon Timestream table. If you are unfamiliar with AWS Quick Starts, refer to the [AWS Quick Start General Information Guide](https://fwd.aws/rA69w?).

This Quick Start is for users who want to insert thousands, or even millions, of utility meter readings into an Amazon Timestream database at a frequent interval. It uses a CloudFormation template and allows for users to create a new Amazon Timestream database/table as a starting point for other solutions, or it can use an existing Amazon Timestream database/table. 

## Costs
There is no cost to use this Quick Start, but you will be billed for any AWS services or resources that this Quick Start deploys. For more information, refer to the [AWS Quick Start General Information Guide](https://fwd.aws/rA69w?).

## Architecture
Deploying this Quick Start with default parameters builds the following environment in the AWS Cloud.\
![image](/docs/images/data_generator.png)

As shown in the above diagram, this Quick Start sets up the following resources:
- An Amazon EventBridge rule, which invokes an "Orchestrator" AWS Lambda function at a user-defined interval
- An "Orchestrator" AWS Lambda function to generate and insert jobs into an Amazon SQS "Worker" queue
- An Amazon SQS "Worker" queue to invoke a "Worker" AWS Lambda function for each message inserted
- A "Worker" AWS Lambda function to generate utility meter readings and insert batches of records into an Amazon Timestream table
- An optional Amazon Timestream database to store utility meter readings

## Launch the Quick Start
1. Download the [AWS CloudFormation template](/templates/device_data_generator_timestream.yaml) for this stack.

2. In the AWS Management Console, select a region from the top tool bar where Amazon Timestream is available. Please refer to the [Amazon Timestream pricing](https://aws.amazon.com/timestream/pricing/) page for availability.\
![image](/docs/images/region_select.png)

3. Navigate to the CloudFormation page, click the "Create stack" button and select "With new resources(standard)".\
![image](/docs/images/stack_create_1.png)

4. Select the "Upload a template file" option and choose the template you downloaded in step 1, then click "Next".\
![image](/docs/images/stack_create_2.png)

5. Enter a name for your stack. You can leave the default parameters or change them to your liking. A few things to note:
- The default frequency of "5" defines how often the Amazon EventBridge rule invokes the "Orchestrator" AWS Lambda function
- Dividing the number of devices for which to generate readings by the number of devices each worker should handle is equal to the number of "Worker" AWS Lambda functions that will be invoked. For example: 1,000,000 devices at each interval, with each Lambda generating readings for 50,000 devices will equate to 10 "Workers" being invoked
- By selecting "Create New" under the "Timestream Configuration" section, a new Amazon Timestream database and table will be created. If you select "Use Existing", please update the database and table fields to reflect resources which you already have defined.

6. Click "Next".\
![image](/docs/images/stack_create_3.png)

7. Accept the defaults on the "Configure stack options" page and click "Next".

8. Scroll down to the bottom of the "Review" page, and select "I acknowledge that AWS CloudFormation might create IAM resources." under the "Capabilities" section.

9. Click "Create stack"

10. Once completed, you can see outputs on the CloudFormation stack's "Outputs" tab. Take note of the TimestreamDatabaseName and TimestreamTableName.\
![image](/docs/images/stack_outputs.png)

11. Once the stack successfully been created, navigate to the Amazon Timestream service page in the AWS Management Console.

12. Navigate to "Query editor" on the left-hand navigation bar.\
![image](/docs/images/timestream_menu.png)

13. Run the following query to confirm data is being inserted into your Amazon Timestream table. Replace TimestreamDatabaseName and TimestreamTableName with the corresponding values from your stack's Outputs tab. You may not receive results until the Amazon EventBridge rule has run for the first time after the interval you defined during stack creation.

```sql
SELECT
*
FROM TimestreamDatabaseName.TimestreamTableName
WHERE time between ago(15m) and now()
ORDER BY time DESC
LIMIT 10
```