# Weather API Project

## **Overview**
This project is a serverless Weather API designed to retrieve and process weather data from the [OpenWeatherMap API](https://openweathermap.org/api). It uses AWS services like Lambda, API Gateway, DynamoDB, and S3 to handle requests, process data, and provide a scalable solution for both real-time and historical weather data access.

## **Features**
- Fetch current weather data for any city (`GET /weather/{city}`).
- Retrieve historical weather data for any city (`GET /weather/history/{city}`).
- Data stored in DynamoDB (or optionally S3) for persistence.
- Infrastructure managed with Terraform for easy deployment.

---

## **Architecture**
- **API Gateway**: Handles HTTP requests and routes them to Lambda functions.
- **AWS Lambda**: Processes requests and communicates with OpenWeatherMap API and DynamoDB/S3.
- **DynamoDB**: Stores both real-time and historical weather data.
- **S3 (Optional)**: Serves as an alternative for storing weather data.
- **Terraform**: Manages AWS infrastructure as code.

---

## **Setup Instructions**

### **Prerequisites**
1. AWS Account with IAM permissions for creating resources (Lambda, API Gateway, DynamoDB, S3).
2. [Terraform](https://www.terraform.io/downloads) installed on your machine.
3. [Node.js](https://nodejs.org/) installed for Lambda development.
4. OpenWeatherMap API Key (sign up [here](https://home.openweathermap.org/users/sign_up)).

### **Steps**
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/weather-api.git
   cd weather-api/terraform
   
   terraform init

   terraform plan

   terraform apply
