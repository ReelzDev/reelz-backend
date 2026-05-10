const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs');
const { uploadToS3 } = require('./storageService');

/**
 * Convert uploaded video to HLS format for adaptive streaming
 * HLS = HTTP Live Streaming (used by Netflix, YouTube, TikTok)
 */
const convertToHLS = (inputPath, videoId) => {
  return new Promise((resolve, reject) => {
    const outputDir = `/tmp/hls_${videoId}`;
    const outputPath = path.join(outputDir, 'index.m3u8');

    if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

    ffmpeg(inputPath)
      // Video settings
      .videoCodec('libx264')
      .audioCodec('aac')
      .outputOptions([
        '-preset fast',
        '-crf 23',
        '-sc_threshold 0',
        '-g 48',
        '-keyint_min 48',
        '-hls_time 4',          // 4 seconds per segment
        '-hls_playlist_type vod',
        '-hls_segment_filename', path.join(outputDir, 'segment_%03d.ts'),
        // Multiple quality levels
        '-map 0:v:0', '-map 0:a:0', '-map 0:v:0', '-map 0:a:0',
        '-s:v:0 1280x720', '-b:v:0 2000k',   // 720p
        '-s:v:1 640x360',  '-b:v:1 800k',    // 360p
        '-var_stream_map', 'v:0,a:0 v:1,a:1',
        '-master_pl_name', 'master.m3u8',
        '-hls_segment_filename', path.join(outputDir, 'stream_%v/segment_%03d.ts'),
      ])
      .output(path.join(outputDir, 'stream_%v/index.m3u8'))
      .on('end', async () => {
        try {
          // Upload all HLS files to S3
          const files = getAllFiles(outputDir);
          const uploadPromises = files.map(async (filePath) => {
            const relativePath = path.relative(outputDir, filePath);
            const s3Key = `hls/${videoId}/${relativePath}`;
            const buffer = fs.readFileSync(filePath);
            await uploadToS3(buffer, path.basename(filePath), `hls/${videoId}/${path.dirname(relativePath)}`);
          });

          await Promise.all(uploadPromises);

          // Clean up temp files
          fs.rmSync(outputDir, { recursive: true, force: true });

          const hlsUrl = `${process.env.AWS_CDN_URL || `https://${process.env.AWS_BUCKET_NAME}.s3.amazonaws.com`}/hls/${videoId}/master.m3u8`;
          resolve(hlsUrl);
        } catch (err) {
          reject(err);
        }
      })
      .on('error', (err) => {
        fs.rmSync(outputDir, { recursive: true, force: true });
        reject(err);
      })
      .run();
  });
};

const getAllFiles = (dir) => {
  const files = [];
  const items = fs.readdirSync(dir);
  items.forEach(item => {
    const fullPath = path.join(dir, item);
    if (fs.statSync(fullPath).isDirectory()) {
      files.push(...getAllFiles(fullPath));
    } else {
      files.push(fullPath);
    }
  });
  return files;
};

/**
 * Get video duration in seconds using ffprobe
 */
const getVideoDuration = (filePath) => {
  return new Promise((resolve, reject) => {
    ffmpeg.ffprobe(filePath, (err, metadata) => {
      if (err) return reject(err);
      resolve(Math.round(metadata.format.duration || 0));
    });
  });
};

module.exports = { convertToHLS, getVideoDuration };
