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
    const { userId } = req.params;
    const db = await connectDB();
    const reportsCollection = db.collection('reports');

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

    const reports = await reportsCollection.find({ garageId }).toArray();

    res.status(200).json(reports);
  } catch (error) {
    console.error("❌ Error fetching reports:", error);
    res.status(500).json({ message: "An error occurred while fetching reports" });
  }
};

// const getReportsToClient = async (req, res) => {
//   try {
//     const { id, name } = req.params;

//     const db = await connectDB();
//     const reportsCollection = db.collection('reports');

//     const reports = await reportsCollection.find({
//       garageId: new ObjectId(id),
//       owner: name
//     }).toArray();

//     const filteredReports = reports.map(report => ({
//       mechanicName: report.mechanicName,
//       make: report.make,
//       cost: report.cost,
//       date: report.date
//     }));

//     res.status(200).json(filteredReports);
//   } catch (error) {
//     console.error("❌ Error fetching reports:", error);
//     res.status(500).json({ message: "An error occurred while fetching reports" });
//   }
// };


const getReportsToClient = async (req, res) => {
  try {
    const { id, name } = req.params;

    const db = await connectDB();
    const reportsCollection = db.collection('reports');

    const reports = await reportsCollection.find({
      garageId: new ObjectId(id),
      owner: name
    }).toArray();

    res.status(200).json(reports);

  } catch (error) {
    console.error("❌ Error fetching reports:", error);
    res.status(500).json({ message: "An error occurred while fetching reports" });
  }
};
const addReport = async (req, res) => {
  try {
    const { owner, cost, plateNumber, date, issue, make, model, year, symptoms, repairDescription, usedParts, status, mechanicName, user_id } = req.body;

    const db = await connectDB();
    const employeesCollection = db.collection('employees');
    const ownersCollection = db.collection('owners'); 

    let garageId;

    const ownerDocument = await ownersCollection.findOne({ _id: new ObjectId(user_id) });
    if (ownerDocument) {
      garageId = ownerDocument.garage_id;
    } else {
      const employee = await employeesCollection.findOne({ _id: new ObjectId(user_id) });
      if (employee) {
        garageId = employee.garage_id;
      } else {
        return res.status(400).json({ message: "Owner or employee not found" });
      }
    }

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
      imageUrls: req.files?.map(file => file.path) || [], // ✅ يقبل بدون صور
      status: "pending",
      mechanicName,
      garageId 
    };

    const reportsCollection = db.collection('reports');
    const result = await reportsCollection.insertOne(newReport);

    const fs = require("fs");
    const path = require("path");

    const csvFilePath = path.join(__dirname, "../data/reports.csv");

    if (!fs.existsSync(csvFilePath)) {
      const headers = "Make,Model,Year,Problem,Symptoms,Solution\n";
      fs.writeFileSync(csvFilePath, headers);
    }

    const row = `${make},${model},${year},${issue},${symptoms},${repairDescription}\n`;
    fs.appendFileSync(csvFilePath, row);

    res.status(201).json({
      message: "Report added successfully",
      reportId: result.insertedId, 
      data: newReport
    });
  } catch (error) {
    console.error("Error adding report:", error);
    res.status(500).json({ message: "An error occurred while adding report" });
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

const updateReport = async (req, res) => {
  try {
    const { id } = req.params;
    const {
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
      status,
      mechanicName,
    } = req.body;

    const db = await connectDB();
    const reportsCollection = db.collection('reports');

    const report = await reportsCollection.findOne({ _id: new ObjectId(id) });
console.log("report :",report);
    if (!report) {
      return res.status(404).json({ message: "Report not found" });
    }

    let updatedFields = {};

    if (owner !== undefined) updatedFields.owner = owner;
    if (cost !== undefined) updatedFields.cost = cost;
    if (plateNumber !== undefined) updatedFields.plateNumber = plateNumber;
    if (date !== undefined) updatedFields.date = date;
    if (issue !== undefined) updatedFields.issue = issue;
    if (make !== undefined) updatedFields.make = make;
    if (model !== undefined) updatedFields.model = model;
    if (year !== undefined) updatedFields.year = year;
    if (symptoms !== undefined) updatedFields.symptoms = symptoms;
    if (repairDescription !== undefined) updatedFields.repairDescription = repairDescription;
    if (usedParts !== undefined) updatedFields.usedParts = usedParts;
    if (status !== undefined) updatedFields.status = status;
    if (mechanicName !== undefined) updatedFields.mechanicName = mechanicName;

    // إذا فيه صور جديدة مرفوعة
    if (req.files && req.files.length > 0) {
      updatedFields.imageUrls = req.files.map(file => file.path);
    }

    await reportsCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: updatedFields }
    );

    res.status(200).json({ message: "Report updated successfully" });

  } catch (error) {
    console.error("❌ Error updating report:", error);
    res.status(500).json({ message: "An error occurred while updating the report" });
  }
};

const deleteReport=async (req,res)=>{

    try {
      const db = await connectDB();
      const reportsCollection = db.collection('reports');
  
      const result = await reportsCollection.deleteOne({ _id: new ObjectId(req.params.id) });
  
      if (result.deletedCount === 0) {
        return res.status(404).json({ message: 'Report not found' });
      }
  
      res.status(200).json({ message: 'Report deleted successfully' });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  
};






module.exports = { getReports, getReportDetails, addReport, upload ,updateReport, deleteReport,getReportsToClient};