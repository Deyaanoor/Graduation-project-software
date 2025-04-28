const connectDB = require('../config/db'); 
const { ObjectId } = require('mongodb');
const getNews = async (req, res) => {
  try {
    const db = await connectDB();
    const newsCollection = db.collection('news'); 

    const newsItems = await newsCollection.find().toArray(); 
    res.status(200).json(newsItems); 
  } catch (error) {
    console.error("❌ Error fetching news:", error);
    res.status(500).json({ message: "An error occurred while fetching news" });
  }
};


const addNews = async (req, res) => {
  try {
    const { title, content, admin, time } = req.body;
    const db = await connectDB();  
    const collection = db.collection('news');  

    const newNews = {
      title,
      content,
      admin,
      time,
    };

    await collection.insertOne(newNews);

    res.status(201).json({
      message: 'News added successfully',
      data: newNews,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred' });
  }
};

module.exports = { getNews, addNews };
