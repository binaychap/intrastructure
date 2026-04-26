const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");

const sqsClient = new SQSClient({});

exports.handler = async (event) => {
  const queueUrl = process.env.SQS_QUEUE_URL;

  if (!queueUrl) {
    throw new Error("SQS_QUEUE_URL is not set");
  }

  const messageBody = JSON.stringify({
    source: "alb",
    timestamp: new Date().toISOString(),
    event,
  });

  await sqsClient.send(
    new SendMessageCommand({
      QueueUrl: queueUrl,
      MessageBody: messageBody,
    }),
  );
  console.log("Message sent to SQS:", messageBody);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Message sent to SQS" }),
  };
};
