const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3002;

// Enable CORS for all routes
app.use(cors({
  origin: true,
  credentials: true
}));

// Proxy endpoint for Blu-ray.com
app.get('/api/blu-ray/collection/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const action = req.query.action || '';

    let url = `https://www.blu-ray.com/community/collection.php?u=${userId}`;
    if (action) {
      url += `&action=${action}`;
    }

    console.log(`Proxying request to: ${url}`);

    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
      },
      timeout: 10000,
      maxRedirects: 5
    });

    // Set appropriate headers
    res.set({
      'Content-Type': response.headers['content-type'] || 'text/html',
      'Cache-Control': 'no-cache'
    });

    res.send(response.data);
  } catch (error) {
    console.error('Proxy error:', error.message);
    res.status(500).json({
      error: 'Failed to fetch data from Blu-ray.com',
      details: error.message
    });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Blu-ray proxy server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
