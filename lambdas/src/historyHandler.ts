import { S3 } from 'aws-sdk';

const BUCKET_NAME = process.env.S3_BUCKET_NAME || 'weather-data-bucket';
const s3 = new S3();

export const handler = async (event: any) => {
    const city = event.pathParameters.city;

    try {
        // Retrieve historical data from S3
        const data = await s3.getObject({
            Bucket: BUCKET_NAME,
            Key: `current/${city}.json`,
        }).promise();

        return {
            statusCode: 200,
            body: data.Body?.toString('utf-8'),
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 404,
            body: JSON.stringify({ error: 'Historical data not found.' }),
        };
    }
};
