import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
} from "@aws-sdk/client-s3";
import { CloudFront } from "@aws-sdk/client-cloudfront";

//import env from "dotenv";
import { uid } from "uid";

//env.config();
const bucket = process.env.BUCKET;
const credentials = {
  region: process.env.AWS_REGION,
  credentials: {
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY as string,
    accessKeyId: process.env.AWS_ACCESS_KEY_ID as string,
  },
};
const client = new S3Client(credentials);
const upload = async (
  folder: string | undefined,
  fileName: string,
  mimetype: string,
  buffer: any
): Promise<any> => {
  let key: string = fileName;
  if (folder) {
    key = folder + "/" + fileName;
  }
  const params = {
    Bucket: bucket,
    Key: key,
    Body: buffer,
    ContentType: mimetype,
    Metadata: {
      ContentType: mimetype,
    },
  };

  return await client.send(new PutObjectCommand(params));
};

const remove = async (folder: string, fileName: string): Promise<any> => {
  const params = {
    Bucket: bucket,
    Key: folder + "/" + fileName,
  };

  return await client.send(new DeleteObjectCommand(params));
};

const invalidate = async (folder: string | undefined, file: string) => {
  let success = false;
  try {
    let path = `/${file}`;
    if(folder){
      path =`/${folder}/${file}`;
    }
    const params = {
      DistributionId: process.env.DISTRIBUTION_ID /* required */,
      InvalidationBatch: {
        CallerReference: uid(16),
        Paths: {
          Quantity: 1,
          Items: [path],
        },
      },
    };
    const cloudFront = new CloudFront(credentials);
    const result = await cloudFront.createInvalidation(params);
    if (result) {
      success = true;
    }
  } catch (e) {
    console.log(e);
  }
  return success;
};

export default {
  upload,
  invalidate,
  remove,
};
