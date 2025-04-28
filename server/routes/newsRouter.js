const express = require("express");
const { getNews, addNews } = require("../controllers/newsController");

const router = express.Router();

router.get("/", getNews);

router.post("/addNew", addNews);


module.exports = router;


