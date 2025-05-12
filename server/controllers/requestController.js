const { ObjectId } = require('mongodb');
const connectDB = require('../config/db');

// ✅ Add request 
const addRequest = async (req, res) => {
  const { userId, garageId, message, location } = req.body;

  try {
    const db = await connectDB();
    const clientsCollection = db.collection('clients');
    const garagesCollection = db.collection('garages');
    const requestsCollection = db.collection('requests');

    const user = await clientsCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const garage = await garagesCollection.findOne({ _id: new ObjectId(garageId) });
    if (!garage) return res.status(404).json({ message: 'Garage not found' });

    const newRequest = {
      userId,
      userName: user.name, 
      garageId,
      message,
      location,
      timestamp: new Date(),
      status: 'pending',
    };

    await requestsCollection.insertOne(newRequest);
    res.status(201).json({ message: 'Request added successfully', request: newRequest });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding request' });
  }
};
// ✅ Get requests by user ID
const getRequestsByUserAndGarageId = async (req, res) => {
    const { userId, garageId } = req.params;

    try {
        const db = await connectDB();
        const requestsCollection = db.collection('requests');
        
        // نحدد الحقول التي نريد إرجاعها فقط باستخدام projection
        const requests = await requestsCollection.find(
            { userId: userId, garageId: garageId },
            {
                projection: {
                    status: 1,
                    timestamp: 1,
                    location: 1,
                    message: 1,
                    userName: 1
                }
            }
        ).toArray();

        if (requests.length === 0) {
            return res.status(404).json({ message: 'No requests found for this user and garage' });
        }
        res.status(200).json(requests);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching requests' });
    }
};

// ✅ Get all requests by ownerId
const getRequests = async (req, res) => {
  const { ownerId } = req.params; 

  try {
    const db = await connectDB();
    const ownersCollection = db.collection('owners');
    const requestsCollection = db.collection('requests');

    // البحث عن مالك الورشة
    const owner = await ownersCollection.findOne({ _id: new ObjectId(ownerId) });

    if (!owner || !owner.garage_id) {
      return res.status(404).json({ message: 'Owner or garage not found' });
    }

    // تحويل الـ garage_id إلى String قبل استخدامه في البحث
    const garageId = owner.garage_id.toString();

    // البحث عن الطلبات المرتبطة بالـ garageId
    const requests = await requestsCollection.find({ garageId: garageId }).toArray();

    if (requests.length === 0) {
      return res.status(404).json({ message: 'No requests found for this garage' });
    }

    res.status(200).json(requests);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching requests' });
  }
};

// ✅ Get request by ID
const getRequestById = async (req, res) => {
  const { id } = req.params;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection('requests');
    const request = await requestsCollection.findOne({ _id: new ObjectId(id) });

    if (!request) return res.status(404).json({ message: 'Request not found' });

    res.status(200).json(request);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching request' });
  }
};

// ✅ Update request status
const updateRequestStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection('requests');
    const updatedRequest = await requestsCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: { status } }
    );

    if (updatedRequest.matchedCount === 0) {
      return res.status(404).json({ message: 'Request not found' });
    }

    res.status(200).json({ message: 'Request status updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating request status' });
  }
};

module.exports = { addRequest, getRequests, getRequestById, updateRequestStatus , getRequestsByUserAndGarageId };
