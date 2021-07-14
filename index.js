const dasha = require("@dasha.ai/sdk");
const fs = require("fs");

//initializing data collection variables 
const question_1_rating = "";
const question_2_rating = "";
const question_3_rating = "";
const question_1_feedback = "";
const question_2_feedback = "";
const question_3_feedback = "";
const call_back = "";

function testRating(rating) 
{
  const ratingNum = Number.parseInt(rating);
  if (ratingNum === 4 || ratingNum === 5)
  {
      return true;
  }
  else if (ratingNum >0 && ratingNum <= 3)
  {
      return false;
  }
      return "Error - rating did not convert to number or converted to a number > 5 or < 1";
}

async function main() 
{
  const app = await dasha.deploy("./app");

  app.connectionProvider = async (conv) =>
    conv.input.phone === "chat"
      ? dasha.chat.connect(await dasha.chat.createConsoleChat())
      : dasha.sip.connect(new dasha.sip.Endpoint("default"));

  app.ttsDispatcher = () => "dasha";

  app.setExternal("check_rating", (args, conv) => 
  {
    const isGood = testRating(q1_rate);
    return isGood;
  }); 

  console.log(isGood);

  await app.start();

  // collecting data from the conversation for use in external services 

  // app.setExternal("call_back", (args, conv) => { call_back = args});
  // console.log(call_back);

  const conv = app.createConversation({ phone: process.argv[2] ?? "" });

  if (conv.input.phone !== "chat") conv.on("transcription", console.log);

  const logFile = await fs.promises.open("./log.txt", "w");
  await logFile.appendFile("#".repeat(100) + "\n");

  conv.on("transcription", async (entry) => {
    await logFile.appendFile(`${entry.speaker}: ${entry.text}\n`);
  });

  conv.on("debugLog", async (event) => {
    if (event?.msg?.msgId === "RecognizedSpeechMessage") {
      const logEntry = event?.msg?.results[0]?.facts;
      await logFile.appendFile(JSON.stringify(logEntry, undefined, 2) + "\n");
    }
  });

  const result = await conv.execute();

  console.log(result.output);

  await app.stop();
  app.dispose();

  await logFile.close();
}

main().catch(() => {});
