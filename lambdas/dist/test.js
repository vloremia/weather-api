const { handler } = require('./weatherHandler');

// Simulated AWS Lambda event
const event = {
    pathParameters: {
        city: 'Melbourne',
        apiKey: '5f723ff8a5e3a0616d47cccd21cf4d46'
    },
};

// Simulated AWS Lambda context (optional)
const context = {};

// Invoke the handler
handler(event, context)
    .then((response) => {
        console.log('Response:', response);
    })
    .catch((error) => {
        console.error('Error:', error);
    });
