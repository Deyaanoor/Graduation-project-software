const { ObjectId } = require('mongodb');
const connectDB = require('../config/db');

const createPlans = async (req, res) => {
  try {
    const db = await connectDB();
    const plansCollection = db.collection('plans');

    const existingPlans = await plansCollection.countDocuments();
    if (existingPlans > 0) {
      return res.status(400).json({ message: 'Plans already exist' });
    }

    const plans = [
      { name: 'trial', price: 0 },
      { name: '6months', price: 1000 },
      { name: '1year', price: 1700 },
    ];

    await plansCollection.insertMany(plans);
    res.status(201).json({ message: 'Plans added successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating plans' });
  }
};

const updatePlan = async (req, res) => {
  const { name } = req.params;
  const { price } = req.body;

  try {
    const db = await connectDB();
    const plansCollection = db.collection('plans');

    const result = await plansCollection.updateOne(
      { name },
      { $set: { price } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: 'Plan not found' });
    }

    res.status(200).json({ message: 'Plan updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating plan' });
  }
};

const getPlanByName = async (req, res) => {
  const { name } = req.params;

  try {
    const db = await connectDB();
    const plansCollection = db.collection('plans');

    const plan = await plansCollection.findOne({ name });
    if (!plan) {
      return res.status(404).json({ message: 'Plan not found' });
    }

    res.status(200).json(plan.price);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching plan' });
  }
};

const getAllPlans = async (req, res) => {
  try {
    const db = await connectDB();
    const plansCollection = db.collection('plans');

    const plans = await plansCollection.find({}).toArray();
    res.status(200).json(plans);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching plans' });
  }
};

module.exports = {
  createPlans,
  updatePlan,
  getPlanByName,
  getAllPlans
};
