const connectDB = require('../config/db');
const { ObjectId } = require('mongodb');

const getMonthlyReportsCount = async (req, res) => {
  try {
    const { userId } = req.body;
    const db = await connectDB();
    const ownersCollection = db.collection('owners');
    const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });
    if (!owner) {
      return res.status(404).json({ message: 'Owner not found' });
    }
    const garageId = owner.garage_id;
    console.log("Garage ID:", garageId);
    const now = new Date(); 
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1); 
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
    const reportsCollection = db.collection('reports');
    const reportsCount = await reportsCollection.countDocuments({
        garageId: new ObjectId(garageId), 
        date: {
            $gte: startOfMonth.toISOString(), 
            $lte: endOfMonth.toISOString(),   
          }
    });
    res.status(200).json({
      count: reportsCount
    });
  } catch (error) {
    console.error('❌ Error fetching monthly reports count:', error);
    res.status(500).json({ message: 'An error occurred while fetching reports count' });
  }
};

const getEmployee = async (req, res) => {
    try {
      const { userId } = req.body;
      const db = await connectDB();
      const ownersCollection = db.collection('owners');
      const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });  
      if (!owner) {
        return res.status(404).json({ message: 'Owner not found' });
      }  
      const garageId = owner.garage_id;
      console.log("Garage ID:", garageId); 
      const employeeCollection = db.collection('employees');
      const employeeCount = await employeeCollection.countDocuments({
          garage_id: new ObjectId(garageId), 
         
      });
  
      res.status(200).json({
        message: 'Employee count fetched successfully',
        count: employeeCount
      });
    } catch (error) {
      console.error('❌ Error fetching employee count:', error);
      res.status(500).json({ message: 'An error occurred while fetching employee count' });
    }
  };

  const getEmployeeSalary = async (req, res) => {
    try {
      const { userId } = req.body;
      const db = await connectDB();
      const ownersCollection = db.collection('owners');
      const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });
      if (!owner) {
        return res.status(404).json({ message: 'Owner not found' });
      }
      const garageId = owner.garage_id;
      console.log("Garage ID:", garageId);
      const employeeCollection = db.collection('employees');
      const result = await employeeCollection.aggregate([
        {
          $match: {
            garage_id: new ObjectId(garageId)
          }
        },
        {
          $group: {
            _id: null,
            totalSalary: { $sum: "$salary" }
          }
        }
      ]).toArray();
  
      const totalSalary = result.length > 0 ? result[0].totalSalary : 0;
      res.status(200).json({
        message: 'Total employee salary fetched successfully',
        totalSalary: totalSalary
      });
    } catch (error) {
      console.error('❌ Error fetching total employee salary:', error);
      res.status(500).json({ message: 'An error occurred while fetching total employee salary' });
    }
  };

  const getMonthlySummary = async (req, res) => {
    try {
      const { userId } = req.body;
      const db = await connectDB();
      const ownersCollection = db.collection('owners');
      const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });
      if (!owner) {
        return res.status(404).json({ message: 'Owner not found' });
      }
      const garageId = owner.garage_id;
      console.log("Garage ID:", garageId);
      const now = new Date(); 
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1); 
      const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
      console.log("Start of Month:", startOfMonth);
      console.log("End of Month:", endOfMonth);
      const employeesCollection = db.collection('employees');
      const totalSalariesResult = await employeesCollection.aggregate([
        {
          $match: { garage_id: new ObjectId(garageId) }
        },
        {
          $group: {
            _id: null,
            totalSalaries: { $sum: "$salary" }
          }
        }
      ]).toArray();
      
      const totalSalaries = totalSalariesResult[0]?.totalSalaries || 0;
      console.log("Total Salaries:", totalSalaries);
      const reportsCollection = db.collection('reports');
      const totalCostResult = await reportsCollection.aggregate([
        {
          $match: {
            garageId: new ObjectId(garageId),
            date: {
              $gte: startOfMonth.toISOString(), 
              $lte: endOfMonth.toISOString(),   
            }
          }
        },
        {
          $project: {
            cost: { $toDouble: "$cost" } 
          }
        },
        {
          $group: {
            _id: null,
            totalCost: { $sum: "$cost" }
          }
        }
      ]).toArray();     
      const totalCost = totalCostResult[0]?.totalCost || 0;
      console.log("Total Cost (from reports):", totalCost);
      const garagesCollection = db.collection('garages');
      const garage = await garagesCollection.findOne({ _id: new ObjectId(garageId) });
      const garageCost = garage?.cost || 0;  
      console.log("Garage Cost:", garageCost);
      const adjustedCost = totalCost - garageCost;
      console.log("Adjusted Total Cost after subtracting Garage Cost:", adjustedCost);
      const netProfit = adjustedCost - totalSalaries;
      console.log("Net Profit:", netProfit);
      res.status(200).json({
        message: 'Monthly summary fetched successfully',
        netProfit:netProfit
      });
    } catch (error) {
      console.error('❌ Error fetching monthly summary:', error);
      res.status(500).json({ message: 'An error occurred while fetching monthly summary' });
    }
  };
  

  const getModelsSummary = async (req, res) => {
    try {
      const { userId } = req.body;
      const db = await connectDB();
      const ownersCollection = db.collection('owners');
      const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });
      if (!owner) {
        return res.status(404).json({ message: 'Owner not found' });
      }
      const garageId = owner.garage_id;
      console.log("Garage ID:", garageId);
      const reportsCollection = db.collection('reports');
      const reports = await reportsCollection.find({
        garageId: new ObjectId(garageId)
      }).toArray();
      const modelCounts = {};
      reports.forEach(report => {
        const model = report.model || "أخرى"; 
        if (modelCounts[model]) {
          modelCounts[model]++;
        } else {
          modelCounts[model] = 1;
        }
      });
      const pieChartData = Object.keys(modelCounts).map(model => ({
        title: model,
        value: modelCounts[model]
      }));
      console.log("Pie Chart Data:", pieChartData);
      res.status(200).json({
        message: 'Models summary fetched successfully',
        data: pieChartData
      });
    } catch (error) {
      console.error('❌ Error in getModelsSummary:', error);
      res.status(500).json({ message: 'An error occurred while fetching models summary' });
    }
  };

  const getTopEmployeesThisMonth = async (req, res) => {
    try {
      const { userId } = req.body;
      const db = await connectDB();
      const ownersCollection = db.collection('owners');
      const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });
      if (!owner) {
        return res.status(404).json({ message: 'Owner not found' });
      }
      const garageId = owner.garage_id;
      console.log("Garage ID:", garageId);
      const now = new Date();
      const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
      const reportsCollection = db.collection('reports');
      const reports = await reportsCollection.find({
        garageId: new ObjectId(garageId),
        date: {
          $gte: startOfMonth.toISOString(),
          $lte: endOfMonth.toISOString(),
        }
      }).toArray();
      const mechanicReportsCount = {};
      reports.forEach(report => {
        const mechanicName = report.mechanicName || "غير معروف";
        if (mechanicReportsCount[mechanicName]) {
          mechanicReportsCount[mechanicName]++;
        } else {
          mechanicReportsCount[mechanicName] = 1;
        }
      });
      const topMechanics = Object.entries(mechanicReportsCount)
        .map(([name, count]) => ({
          label: name,
          value: count
        }))
        .sort((a, b) => b.value - a.value) 
        .slice(0, 5); 
  
      console.log("Top Mechanics This Month:", topMechanics);
      return res.status(200).json({
        message: 'Top employees this month fetched successfully',
        data: topMechanics
      });
    } catch (error) {
      console.error('❌ Error in getTopEmployeesThisMonth:', error);
      return res.status(500).json({ message: error.message });
    }
  };


  const getReports = async (req, res) => {
    try {
      const { userId } = req.body;
      const db = await connectDB();
      const reportsCollection = db.collection('reports');
  
      const owner = await db.collection('owners').findOne({ _id: new ObjectId(userId) });
  
      let garageId;
      if (owner) {
        const garage = await db.collection('garages').findOne({ owner_id: owner._id });
        garageId = garage ? garage._id : null;
      } else {
        return res.status(404).json({ message: 'User not found' });
      }
  
      if (!garageId) {
        return res.status(404).json({ message: 'Garage not found for this user' });
      }
  
     
      const reports = await reportsCollection
        .find({ garageId })
        .sort({ date: -1 })  
        .limit(5)  
        .project({
          _id: 0,       
          owner: 1,     
          issue: 1,    
          date: 1       
        })
        .toArray();
  
      res.status(200).json(reports);
    } catch (error) {
      console.error("❌ Error fetching reports:", error);
      res.status(500).json({ message: "An error occurred while fetching reports" });
    }
  };
  
  
module.exports = { getMonthlyReportsCount,getEmployee,getEmployeeSalary,getMonthlySummary,
getModelsSummary,getTopEmployeesThisMonth ,getReports };
