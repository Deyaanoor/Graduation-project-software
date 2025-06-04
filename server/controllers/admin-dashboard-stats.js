const { ObjectId } = require("mongodb");

const connectDB = require("../config/db");

const getDashboardStats = async (req, res) => {
  try {
    const db = await connectDB();

    const garagesCollection = db.collection("garages");
    const ownersCollection = db.collection("owners");
    const contactMessagesCollection = db.collection("contact_messages");
    const registration_requests = db.collection("registration_requests");
    const garagesCount = await garagesCollection.countDocuments({
      status: { $regex: /^active$/i },
    });
    const garagesCountIn = await garagesCollection.countDocuments({
      status: { $regex: /^inactive$/i },
    });

    const subscriptionRequestsCount =
      await registration_requests.countDocuments({
        status: { $regex: /^pending$/i },
      });

    const contactMessagesCount = await contactMessagesCollection.countDocuments(
      { status: { $regex: /^pending$/i } }
    );

    const trialGaragesCount = await garagesCollection.countDocuments({
      cost: 0,
    });

    res.status(200).json({
      garagesCount,
      subscriptionRequestsCount,
      contactMessagesCount,
      trialGaragesCount,
      garagesCountInactive: garagesCountIn,
    });
  } catch (error) {
    console.error("❌ Error fetching dashboard stats:", error);
    res.status(500).json({
      message: "Error fetching dashboard statistics",
    });
  }
};

module.exports = { getDashboardStats };
