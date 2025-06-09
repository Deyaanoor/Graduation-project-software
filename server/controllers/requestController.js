const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");

// ✅ Add request
const addRequest = async (req, res) => {
  const { userId, garageId, message, location } = req.body;

  if (!ObjectId.isValid(userId) || !ObjectId.isValid(garageId)) {
    return res.status(400).json({ message: "userId أو garageId غير صالح" });
  }

  try {
    const db = await connectDB();
    const clientsCollection = db.collection("clients");
    const garagesCollection = db.collection("garages");
    const requestsCollection = db.collection("requests");

    const user = await clientsCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) return res.status(404).json({ message: "User not found" });

    const garage = await garagesCollection.findOne({
      _id: new ObjectId(garageId),
    });
    if (!garage) return res.status(404).json({ message: "Garage not found" });

    const newRequest = {
      userId: userId,
      userName: user.name,
      garageId: garageId,
      location,
      timestamp: new Date(),
      status: "pending",
      messages: [
        {
          sender: "user",
          message,
          timestamp: new Date(),
        },
      ],
    };

    await requestsCollection.insertOne(newRequest);
    res
      .status(201)
      .json({ message: "Request added successfully", request: newRequest });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error adding request" });
  }
};

const addMessageToRequest = async (req, res) => {
  const { requestId } = req.params;
  const { sender, message } = req.body;

  if (!["user", "owner"].includes(sender)) {
    return res.status(400).json({ message: "Invalid sender type" });
  }

  try {
    const db = await connectDB();
    const requestsCollection = db.collection("requests");

    const result = await requestsCollection.updateOne(
      { _id: new ObjectId(requestId) },
      {
        $push: {
          messages: {
            sender,
            message,
            timestamp: new Date(),
          },
        },
      }
    );

    if (result.modifiedCount === 0) {
      return res
        .status(404)
        .json({ message: "Request not found or message not added" });
    }

    res.status(200).json({ message: "Message added successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error adding message to request" });
  }
};

const getRequestMessages = async (req, res) => {
  const { requestId } = req.params;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection("requests");

    const request = await requestsCollection.findOne(
      { _id: new ObjectId(requestId) },
      { projection: { messages: 1 } }
    );

    if (!request) return res.status(404).json({ message: "Request not found" });

    res.status(200).json(request.messages);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching messages" });
  }
};

// ✅ Get requests by user ID
const getRequestsByUserAndGarageId = async (req, res) => {
  const { userId, garageId } = req.params;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection("requests");

    const requests = await requestsCollection
      .find(
        { userId: userId, garageId: garageId },
        {
          projection: {
            status: 1,
            timestamp: 1,
            location: 1,
            message: 1,
            userName: 1,
          },
        }
      )
      .toArray();

    // إذا ما في نتائج، رجّع مصفوفة فاضية مع رسالة
    if (requests.length === 0) {
      return res.status(200).json({
        message: "No requests found for this user and garage.",
        data: [],
      });
    }

    // رجّع النتائج بشكل عادي
    res.status(200).json({
      message: "Requests fetched successfully.",
      data: requests,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching requests" });
  }
};

// ✅ Get all requests by ownerId
const getRequests = async (req, res) => {
  const { ownerId } = req.params;

  try {
    const db = await connectDB();
    const ownersCollection = db.collection("owners");
    const requestsCollection = db.collection("requests");

    const owner = await ownersCollection.findOne({
      _id: new ObjectId(ownerId),
    });
    if (!owner || !owner.garage_id) {
      return res.status(404).json({ message: "Owner or garage not found" });
    }
    const garageId = owner.garage_id.toString();
    const requests = await requestsCollection
      .find({ garageId: garageId })
      .toArray();

    if (requests.length === 0) {
      return res
        .status(404)
        .json({ message: "No requests found for this garage" });
    }

    res.status(200).json(requests);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching requests" });
  }
};

// ✅ Get request by ID
const getRequestById = async (req, res) => {
  const { id } = req.params;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection("requests");
    const request = await requestsCollection.findOne({ _id: new ObjectId(id) });

    if (!request) return res.status(404).json({ message: "Request not found" });

    res.status(200).json(request);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching request" });
  }
};

// ✅ Update request status
const updateRequestStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection("requests");
    const updatedRequest = await requestsCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: { status } }
    );

    if (updatedRequest.matchedCount === 0) {
      return res.status(404).json({ message: "Request not found" });
    }

    res.status(200).json({ message: "Request status updated successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error updating request status" });
  }
};

const deleteRequest = async (req, res) => {
  const { requestId } = req.params;

  try {
    const db = await connectDB();
    const requestsCollection = db.collection("requests");

    const result = await requestsCollection.deleteOne({
      _id: new ObjectId(requestId),
    });

    if (result.deletedCount === 0) {
      return res
        .status(404)
        .json({ message: "الطلب غير موجود أو لم يتم حذفه" });
    }

    res.status(200).json({ message: "تم حذف الطلب بنجاح" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "حدث خطأ أثناء حذف الطلب" });
  }
};

module.exports = {
  addRequest,
  getRequests,
  getRequestById,
  updateRequestStatus,
  getRequestsByUserAndGarageId,
  addMessageToRequest,
  getRequestMessages,
  deleteRequest,
};
