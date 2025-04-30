const express = require("express");
const { getNews, addNews,deleteNews,updateNews } = require("../controllers/newsController");

const router = express.Router();

router.get("/user/:userId", getNews); // 🔥

router.post("/addNew", addNews);
router.put("/update/:id", updateNews);
router.delete("/:id", deleteNews);

module.exports = router;


