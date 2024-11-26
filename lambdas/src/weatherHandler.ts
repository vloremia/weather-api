import axios from 'axios';
import { S3 } from 'aws-sdk';

const BUCKET_NAME = process.env.S3_BUCKET_NAME || 'weather-data-bucket';
const s3 = new S3();

export const handler = async (event: any) => {
    const city = event.pathParameters.city;
    const apiKey = process.env.OPENWEATHER_API_KEY;
    const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}`;

    try {
        // Fetch data from OpenWeatherMap
        const response = await axios.get(url);
        const weatherData = response.data;

        // Store the response in S3
        await s3.putObject({
            Bucket: BUCKET_NAME,
            Key: `current/${city}.json`,
            Body: JSON.stringify(weatherData),
            ContentType: 'application/json',
        }).promise();

        return {
            statusCode: 200,
            body: JSON.stringify(weatherData),
        };
    } catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Failed to fetch weather data.' }),
        };
    }
};
