const express = require('express'); 
const multer = require('multer'); 
const { Storage } = require('@google-cloud/storage'); 
const path = require('path');

const app = express(); 
const upload = multer({ storage: multer.memoryStorage() }); 
const storage = new Storage(); 

const bucketName = process.env.ASSETS_BUCKET; // injected by Terraform / Cloud Run env var 
if (!bucketName) { 
  console.error('ASSETS_BUCKET env var is missing'); 
  process.exit(1); 
} 

// serve static HTML files from ../public
app.use(express.static(path.join(__dirname, '..', 'public')));

const nowIso = () => new Date().toISOString(); 

app.get('/', (req, res) => { 
  res.send(`Hello World — ${nowIso()}`); 
}); 

app.get('/health', (req, res) => { 
  res.json({ status: 'ok', ts: nowIso() }); 
}); 

// POST /upload with form field "file" 
app.post('/upload', upload.single('file'), async (req, res) => { 
  try { 
    if (!req.file) return res.status(400).send('No file uploaded'); 

    // store directly in bucket root (no 'assets/' folder) 
    const filename = `${Date.now()}-${req.file.originalname}`; 
    const file = storage.bucket(bucketName).file(filename); 

    await file.save(req.file.buffer, { 
      contentType: req.file.mimetype, 
    }); 

    console.log(`Uploaded ${filename} to gs://${bucketName}`); 
    res.json({ status: 'uploaded', path: `gs://${bucketName}/${filename}` }); 
  } catch (err) { 
    console.error('Upload failed', err); 
    res.status(500).json({ error: 'upload_failed' }); 
  } 
}); 

// simple error handler 
app.use((err, req, res, next) => { 
  console.error('Unhandled error:', err); 
  res.status(500).json({ error: 'internal_server_error' }); 
}); 

const port = process.env.PORT || 8080; 
app.listen(port, '0.0.0.0', () => console.log(`Listening on ${port}`)); 
