const connectDB = require('../config/db');
const { ObjectId } = require('mongodb');

const ADMIN_ID = '5f6f5b7b3e9a1b1c8cd7d2a2';

const addGarage = async (req, res) => {
  try {
    const { name, location, ownerName, ownerEmail ,cost } = req.body;

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const ownerCollection = db.collection('owners');

    let owner = await ownerCollection.findOne({ email: ownerEmail });
    if (!owner) {
      const newOwner = {
        name: ownerName,
        email: ownerEmail,
        
      };
      const result = await ownerCollection.insertOne(newOwner);
      owner = {
        _id: result.insertedId,
        ...newOwner
      };
    }

    const newGarage = {
      name,
      location,
      ownerName,
      ownerEmail,
      cost,
      admin_id: new ObjectId(ADMIN_ID),
      owner_id: new ObjectId(owner._id),
    };

    const garageResult = await garagesCollection.insertOne(newGarage);

    // ✅ تحديث سجل الـ owner وإضافة garage_id
    await ownerCollection.updateOne(
      { _id: owner._id },
      { $set: { garage_id: garageResult.insertedId } }
    );

    res.status(201).json({
      message: 'Garage added successfully',
      data: {
        ...newGarage,
        _id: garageResult.insertedId
      },
    });
  } catch (error) {
    console.error('❌ Error adding garage:', error);
    res.status(500).json({ message: 'An error occurred while adding the garage' });
  }
};


const getGarages = async (req, res) => {
  try {
    const db = await connectDB();
    const garagesCollection = db.collection('garages');

    const garages = await garagesCollection.find().toArray(); 
    res.status(200).json(garages); 
  } catch (error) {
    console.error('❌ Error fetching garages:', error);
    res.status(500).json({ message: 'An error occurred while fetching garages' });
  }
};

const getGarageById = async (req, res) => {
  try {
    const { id } = req.params; 

    const db = await connectDB();
    const garagesCollection = db.collection('garages');

    const garage = await garagesCollection.findOne({ _id: new ObjectId(id) });

    if (!garage) {
      return res.status(404).json({ message: 'Garage not found' });
    }

    res.status(200).json(garage); 
  } catch (error) {
    console.error('❌ Error fetching garage by ID:', error);
    res.status(500).json({ message: 'An error occurred while fetching the garage' });
  }
};

const deleteGarage = async (req, res) => {
  try {
    const { id } = req.params;

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const ownerCollection = db.collection('owners');
    const reportsCollection = db.collection('reports');
    const notificationsCollection = db.collection('notifications');
    const employeesCollection = db.collection('employees');
    const usersCollection = db.collection('users');

    const garage = await garagesCollection.findOne({ _id: new ObjectId(id) });
    if (!garage) {
      return res.status(404).json({ message: 'Garage not found' });
    }

    const owner = await ownerCollection.findOne({ _id: new ObjectId(garage.owner_id) });
    const ownerEmail = owner?.email;
    const employees = await employeesCollection.find({ garageId: new ObjectId(id) }).toArray();
    const employeeEmails = employees.map(emp => emp.email);
    const allEmailsToDelete = [ownerEmail, ...employeeEmails];

    if (allEmailsToDelete.length > 0) {
      await usersCollection.deleteMany({
        email: { $in: allEmailsToDelete }
      });
    }
    if (ownerEmail) {
      await usersCollection.deleteOne({ email: ownerEmail });
    }
    await reportsCollection.deleteMany({ garageId: new ObjectId(id) });
    await notificationsCollection.deleteMany({ garageId: new ObjectId(id) });
    await employeesCollection.deleteMany({ garageId: new ObjectId(id) });
    await ownerCollection.deleteOne({ _id: new ObjectId(garage.owner_id) });
    await garagesCollection.deleteOne({ _id: new ObjectId(id) });

    res.status(200).json({ message: 'Garage and related data deleted successfully' });
  } catch (error) {
    console.error('❌ Error deleting garage:', error);
    res.status(500).json({ message: 'An error occurred while deleting the garage' });
  }
};


const updateGarage = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, location, ownerName, ownerEmail, cost } = req.body;

    const db = await connectDB();
    const garagesCollection = db.collection('garages');
    const ownerCollection = db.collection('owners');
    const usersCollection = db.collection('users');

    const garage = await garagesCollection.findOne({ _id: new ObjectId(id) });
    if (!garage) {
      return res.status(404).json({ message: 'Garage not found' });
    }
    const owner = await ownerCollection.findOne({ _id: new ObjectId(garage.owner_id) });
    if (!owner) {
      return res.status(404).json({ message: 'Owner not found' });
    }
    const oldOwnerEmail = owner.email;

    await usersCollection.updateOne(
      { email: oldOwnerEmail },
      { $set: { email: ownerEmail, name: ownerName } }
    );
    await ownerCollection.updateOne(
      { _id: new ObjectId(owner._id) },
      { $set: { name: ownerName, email: ownerEmail } }
    );
    await garagesCollection.updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          name,
          location,
          cost,
          ownerName,
          ownerEmail,
        }
      }
    );

    res.status(200).json({ message: 'Garage and related owner/user updated successfully' });

  } catch (error) {
    console.error('❌ Error updating garage:', error);
    res.status(500).json({ message: 'An error occurred while updating the garage' });
  }
};

const getGarageLocations = async (req, res) => {
  try {
    const db = await connectDB();
    const garagesCollection = db.collection('garages');

    const locations = await garagesCollection
      .find({}, { projection: { name: 1, location: 1 } }) 
      .toArray();

    const parsedLocations = locations.map(garage => ({
      garageId: garage._id.toString(), 
      name: garage.name,
      location: JSON.parse(garage.location) 
    }));

    res.status(200).json(parsedLocations);
  } catch (error) {
    console.error('❌ Error fetching garage locations:', error);
    res.status(500).json({ message: 'An error occurred while fetching locations' });
  }
};


const getGarageInfo = async (req, res) => {
  const userId = req.params.userId;

  try {
    const db = await connectDB();

    const employeesCollection = db.collection('employees');
    const ownersCollection = db.collection('owners');
    const garagesCollection = db.collection('garages');

    let employee = await employeesCollection.findOne({_id: new ObjectId(userId) });

    let garageId;

    if (employee) {
      garageId = employee.garage_id;
    } else {
      const owner = await ownersCollection.findOne({_id: new ObjectId(userId) });
      if (owner) {
        garageId = owner.garage_id;
      } else {
        return res.status(404).json({ message: 'User not found in employees or owners' });
      }
    }

    const garage = await garagesCollection.findOne({_id: new ObjectId(garageId) });

    if (!garage) {
      return res.status(404).json({ message: 'Garage not found' });
    }

    res.status(200).json({
      name: garage.name,
      ownerName: garage.ownerName,
      ownerEmail: garage.ownerEmail,
      location: garage.location,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch garage data' });
  }
};




module.exports = { addGarage, getGarages, getGarageById, deleteGarage, updateGarage, getGarageLocations,getGarageInfo};
