"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const axios_1 = __importDefault(require("axios"));
const aws_sdk_1 = require("aws-sdk");
const BUCKET_NAME = process.env.S3_BUCKET_NAME || 'weather-data-bucket';
const s3 = new aws_sdk_1.S3();
const handler = async (event) => {
    const city = event.pathParameters.city;
    const apiKey = process.env.OPENWEATHER_API_KEY;
    const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}`;
    try {
        // Fetch data from OpenWeatherMap
        const response = await axios_1.default.get(url);
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
    }
    catch (error) {
        console.error(error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Failed to fetch weather data.' }),
        };
    }
};
exports.handler = handler;
