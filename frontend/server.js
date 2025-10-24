const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const PORT = 3000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

app.post('/submit-form', async (req, res) => {
  try {
    const response = await axios.post('http://backend:5000/process', req.body, {
      headers: { 'Content-Type': 'application/json' }
    });
    res.send(`<pre>${JSON.stringify(response.data, null, 2)}</pre>`);
    res.send(response.data.message);
  } catch (error) {
    res.status(500).send('Error communicating with Flask backend');
  }
});


app.listen(PORT, () => {
  console.log(`Express frontend running at http://localhost:${PORT}`);
});