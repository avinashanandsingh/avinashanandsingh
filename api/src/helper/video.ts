import * as fmpeg from "@ffmpeg-installer/ffmpeg";
import ffmpeg from "fluent-ffmpeg";

const ffmpegPath = fmpeg.path;
ffmpeg.setFfmpegPath(ffmpegPath);

export default {
  compress: async (filePath: string, originalFilePath: string) => {
    return await new Promise((resolve, reject) => {
      ffmpeg(filePath)
        .output(originalFilePath)
        .videoCodec("libx264")
        .size("50%")
        .on("error", (err) => {
          console.log("Error:", err.message);
          reject(false);
        })
        .on("progress", (progress) => {
          console.log("Progress:", progress.frames);
        })
        .on("end", () => {
          console.log("Video compression complete!");
          resolve(true);
        })
        .run();
    });
  },
};
