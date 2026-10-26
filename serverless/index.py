import json
import base64
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

try:
    import pydevd_pycharm
    # Change 'localhost' to '172.17.0.1' so it routes outside the Docker container
    pydevd_pycharm.settrace('172.17.0.1', port=5678, stdout_to_server=True, stderr_to_server=True, suspend=True)
    logger.info("⏸️ Lambda paused. Attached to PyCharm!")
except Exception as e:
    logger.error(f"Failed to connect to PyCharm debugger: {e}")


dynamo_db = boto3.resource('dynamodb')
table = dynamo_db.Table('product-recalls')

def handler(event, context):
    print("--------------------------------------------------")
    print("🚀 Lambda Triggered by Event Source Batch!")
    print("--------------------------------------------------")

    records = event.get("Records", [])
    total_messages = len(records)

    print(f"Processing {total_messages} records...")

    total_success = 0
    total_failure = 0

    if not records:
        print("No records found in this batch execution")
        return {"statusCode": 200, "body": "No records found in batch"}

    for record in records:
        data = None
        try:
            # Kakfa sends the data in raw bytes, we need to decode those bytes
            data = json.loads(record['body'])

            response = table.put_item(
                Item = {
                    'recall_id': data['recallNumber'],
                    'recalling_firm' : data['recallingFirm'],
                    'product_description' : {
                        'company_name': data.get('companyName', 'UNKNOWN'),
                        'product_name': data.get('productName', 'UNKNOWN'),
                        'identifiers': data.get('identifiers', 'UNKNOWN')
                    },
                    'recall_reason': data.get('recallReason', 'UNKNOWN'),
                    'classification' : data.get('classification', 'UNKNOWN'),
                    'status' : data.get('status', 'UNKNOWN'),
                    'parsed_date' : data.get('parsedDate', 'UNKNOWN'),
                    'dist_location': data.get('distLocation', 'UNKNOWN'),
                    'source_agency': data.get('sourceAgency', 'UNKNOWN'),
                    'info_url': data.get('infoUrl', 'UNKNOWN')
                }
            )

            status_code = response.get('ResponseMetadata', {}).get('HTTPStatusCode')
            if status_code == 200:
                total_success += 1
            else:
                total_failure += 1

            print(f"Successfully persisted recall record {data['recallNumber']}")

        except Exception as e:
            print(f"Exception raised for record {data['recallNumber']} - {e}")
            total_failure += 1

    print(f"{total_success}/{total_messages} Records persisted in batch execution.")
    return {"statusCode": 200, "body": "Kafka message batch processed successfully."}