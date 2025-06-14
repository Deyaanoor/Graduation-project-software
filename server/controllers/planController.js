const { ObjectId } = require('mongodb');
const connectDB = require('../config/db');

const addSinglePlan = async (req, res) => {
  try {
    const db = await connectDB();
    const plansCollection = db.collection('plans');

    const { name, price } = req.body;

    if (!name || price == null) {
      return res.status(400).json({ message: 'Name and price are required' });
    }

    const existingPlan = await plansCollection.findOne({ name });
    if (existingPlan) {
      return res.status(400).json({ message: 'Plan already exists' });
    }

    await plansCollection.insertOne({ name, price });
    res.status(201).json({ message: 'Plan added successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding plan' });
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

const deletePlanById = async (req, res) => {
  try {
    const db = await connectDB();
    const plansCollection = db.collection('plans');

    const { id } = req.params;

    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ message: 'Invalid plan ID' });
    }

    const result = await plansCollection.deleteOne({ _id: new ObjectId(id) });

    if (result.deletedCount === 0) {
      return res.status(404).json({ message: 'Plan not found' });
    }

    res.status(200).json({ message: 'Plan deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error deleting plan' });
  }
};


module.exports = {
  
  updatePlan,
  getPlanByName,
  getAllPlans,
  deletePlanById,
  addSinglePlan
};
