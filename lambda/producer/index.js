exports.handler = async (event) => {
  console.log("Producer event:", JSON.stringify(event));
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Producer Lambda executed" }),
  };
};
