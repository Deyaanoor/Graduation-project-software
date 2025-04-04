const connectDB = require('../config/db');
const { ObjectId } = require('mongodb');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;
const multerStorageCloudinary = require('multer-storage-cloudinary').CloudinaryStorage;

cloudinary.config({
  cloud_name: "dmqgqu7st",
  api_key: "757442912861293",
  api_secret: "ifXxCdY2tdgnGG5y_55a_ZlDPKM"
});

const storage = new multerStorageCloudinary({
  cloudinary: cloudinary,
  params: {
    folder: 'reports',
    allowed_formats: ['jpg', 'jpeg', 'png'],
  },
});

const upload = multer({ storage: storage });

const getReports = async (req, res) => {
  try {
    const db = await connectDB();
    const reportsCollection = db.collection('reports');

    const reports = await reportsCollection.find({}, {
      projection: { 
        owner: 1,
        cost: 1,
        plateNumber: 1,
        date: 1,
        issue: 1,
        make:1,
        model:1,
        year:1,
        symptoms:1,
        repairDescription: 1,
        usedParts: 1,
        imageUrls: 1 
      }
    }).toArray();

    res.status(200).json(reports);
  } catch (error) {
    console.error("❌ Error fetching reports:", error);
    res.status(500).json({ message: "An error occurred while fetching reports" });
  }
};

const getReportDetails = async (req, res) => {
  try {
    const { id } = req.params;
    const db = await connectDB();
    const reportsCollection = db.collection('reports');

    const report = await reportsCollection.findOne({ _id: new ObjectId(id) });

    if (!report) {
      return res.status(404).json({ message: "Report not found" });
    }

    res.status(200).json(report);
  } catch (error) {
    console.error("❌ Error fetching report details:", error);
    res.status(500).json({ message: "An error occurred while fetching report details" });
  }
};

const addReport = async (req, res) => {
  try {
    console.log("Request body:", req.body);
    console.log("Uploaded files:", req.files); // تغيير إلى req.files

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: "No images uploaded" });
    }

    const { owner, cost, plateNumber, date, issue,make,model,year,symptoms ,repairDescription, usedParts } = req.body;
    
    const newReport = {
      owner,
      cost,
      plateNumber,
      date,
      issue,
      make,
      model,
      year,
      symptoms,
      repairDescription,
      usedParts,
      imageUrls: req.files.map(file => file.path)
    };

    const db = await connectDB();
    const reportsCollection = db.collection('reports');
    await reportsCollection.insertOne(newReport);

    res.status(201).json({
      message: "Report added successfully",
      data: newReport
    });
  } catch (error) {
    console.error("Error adding report:", error);
    res.status(500).json({ message: "An error occurred while adding report" });
  }
};

module.exports = { getReports, getReportDetails, addReport, upload };