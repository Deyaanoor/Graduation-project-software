const { MongoClient } = require("mongodb");
const dotenv = require("dotenv");
dotenv.config();

const connectDB = require("../config/db");

const getAllNews = async (req, res) => {
  try {
    const db = await connectDB(); 
    const collection = db.collection("news");

    const newsItems = await collection.find().toArray(); 
    res.json(newsItems);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'خطأ في الخادم' });
  }
};

const addNews = async (req, res) => {
  try {
    const { title, content, admin, time } = req.body;

    if (!title || !content || !admin || !time) {
      return res.status(400).json({ message: "يجب توفير جميع الحقول!" });
    }

    const db = await connectDB();
    const collection = db.collection("news");

    const newNews = { title, content, admin, time };
    await collection.insertOne(newNews);

    res.status(201).json({ message: "تم إضافة الخبر بنجاح!", data: newNews });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "خطأ في الخادم" });
  }
};

module.exports = { getAllNews, addNews };
