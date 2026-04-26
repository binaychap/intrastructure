exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event));
  // Your business logic here
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Consumer Lambda executed successfully" }),
  };
};
