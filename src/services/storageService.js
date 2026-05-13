const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION,
});

const uploadToS3 = async (fileBuffer, originalName, folder = 'videos') => {
  const ext = path.extname(originalName);
  const key = `${folder}/${uuidv4()}${ext}`;

  const params = {
    Bucket: process.env.AWS_BUCKET_NAME,
    Key: key,
    Body: fileBuffer,
    ContentType: getContentType(ext),
  };

  const result = await s3.upload(params).promise();
  return {
    url: result.Location,
    key: result.Key,
  };
};

const deleteFromS3 = async (key) => {
  await s3.deleteObject({
    Bucket: process.env.AWS_BUCKET_NAME,
    Key: key,
  }).promise();
};

const getContentType = (ext) => {
  const types = {
    '.mp4': 'video/mp4',
    '.mov': 'video/quicktime',
    '.avi': 'video/x-msvideo',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.m3u8': 'application/x-mpegURL',
    '.ts': 'video/MP2T',
  };
  return types[ext.toLowerCase()] || 'application/octet-stream';
};

module.exports = { uploadToS3, deleteFromS3 };
