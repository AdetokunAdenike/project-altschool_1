// app.js
const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Serve static files
app.use(express.static(path.join(__dirname, 'static')));

// Start the server
app.listen(PORT, '0.0.0.0', () => {
	console.log(`Node server is running at http://localhost:${PORT}`);
});
