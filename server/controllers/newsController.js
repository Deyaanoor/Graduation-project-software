const connectDB = require('../config/db'); 
const { ObjectId } = require('mongodb');

const addNews = async (req, res) => {
  try {
    const db = await connectDB();
    const { title, content, admin, userId } = req.body; 

    if (!title || !content || !admin || !userId) {
      return res.status(400).json({ 
        message: "All fields are required: title, content, admin, userId",
        received: { title, content, admin, userId }
      });
    }

    const employee = await db.collection('employees').findOne({ _id: new ObjectId(userId) });
    const owner = await db.collection('owners').findOne({ _id: new ObjectId(userId) });

    let garageId;
    if (owner) {
      const garage = await db.collection('garages').findOne({ owner_id: owner._id });
      garageId = garage?._id;
    } else if (employee) {
      const garage = await db.collection('garages').findOne({ _id: employee.garage_id });
      garageId = garage?._id;
    } else {
      return res.status(404).json({ message: 'User not found' });
    }

    if (!garageId) {
      return res.status(404).json({ message: 'Garage not found for this user' });
    }
    const newNews = {
      title,
      content,
      admin,
      garageId,
      time: new Date()
    };

    const result = await db.collection('news').insertOne(newNews);
    res.status(201).json({ 
      message: "News added successfully",
      id: result.insertedId,
      news: newNews
    });

  } catch (error) {
    console.error("❌ Error adding news:", error);
    res.status(500).json({ 
      message: "An error occurred while adding news",
      error: error.message 
    });
  }
};

const getNews = async (req, res) => {
  try {
    const { userId } = req.params;
    const db = await connectDB();
    const newsCollection = db.collection('news');

    const employee = await db.collection('employees').findOne({ _id: new ObjectId(userId) });
    const owner = await db.collection('owners').findOne({ _id: new ObjectId(userId) });

    let garageId;
    if (owner) {
      const garage = await db.collection('garages').findOne({ owner_id: owner._id });
      garageId = garage ? garage._id : null;
    } else if (employee) {
      const garage = await db.collection('garages').findOne({ _id: employee.garage_id });
      garageId = garage ? garage._id : null;
    } else {
      return res.status(404).json({ message: 'User not found' });
    }

    if (!garageId) {
      return res.status(404).json({ message: 'Garage not found for this user' });
    }

    const newsList = await newsCollection.find({ garageId }).toArray();

    res.status(200).json(newsList);
  } catch (error) {
    console.error("❌ Error fetching news:", error);
    res.status(500).json({ message: "An error occurred while fetching news" });
  }
};
const updateNews = async (req, res) => {
  try {
    const db = await connectDB();
    const { title, content } = req.body; 
    const { id } = req.params;
    console.log("id:",id);

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid news ID' });
    }
    const result = await db.collection('news').findOneAndUpdate(
      { _id: new ObjectId(id) },
      { $set: { title, content,time: new Date()} },
      { returnDocument: 'after' }
    );
    console.log(result);


 
    res.status(200).json(result.value);
  } catch (error) {
    console.error('❌ Error updating news:', error);
    res.status(500).json({ message: 'Error updating news' });
  }
};

const deleteNews = async (req, res) => {
  try {
    const db = await connectDB();
    await db.collection('news').deleteOne({ _id: new ObjectId(req.params.id) });
    res.status(200).json({ message: 'News deleted successfully' });
  } catch (error) {
    console.error('❌ Error deleting news:', error);
    res.status(500).json({ message: 'Error deleting news' });
  }
};

module.exports = { getNews, addNews,updateNews,deleteNews};
