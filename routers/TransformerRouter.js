const express = require("express");
//own module
const transformerController = require('../controllers/TransformerController');

const transformerRouter = express.Router();


transformerRouter.get("/",transformerController.homePage);
transformerRouter.post("/",transformerController.convert);

module.exports = transformerRouter;