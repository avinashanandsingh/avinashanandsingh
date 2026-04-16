
import fs from "fs";
import { makeExecutableSchema } from "@graphql-tools/schema";
import { constraintDirectiveTypeDefs } from "graphql-constraint-directive";
let schemas = "";

const dirPath = "./src/types/";
//const dirPath = "/app/viator/src/types/";

fs.readdirSync(dirPath).forEach((file) => {
  if (file !== "index.js" && file !== "index.ts") {
    let schema = fs.readFileSync(dirPath + file).toString();
    schemas += schema + "\n";
  }
});

let executableSchema = makeExecutableSchema({
  typeDefs: [constraintDirectiveTypeDefs, schemas],
});

export default executableSchema;
