const express = require('express');
const fileUpload = require("express-fileupload");
const fs = require("fs");
const decompress = require("decompress");
const path = require("path");
const transformerRouter = require('./routers/TransformerRouter');

const PORT = 3001;

const app = express()

app.use(fileUpload());
app.use("/trasformatore",transformerRouter);
app.use(express.static(path.join(__dirname,"static")));


app.listen(PORT, () => console.log(`Example app listening at http://localhost:${PORT}`));
