const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");
// const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY); // تأكد من ضبط مفتاح Stripe في env

const applyGarage = async (req, res) => {
  const { garageName, garageLocation, subscriptionType, paymentIntentId } =
    req.body;
  const userId = req.body.user_id;

  if (!garageName || !garageLocation || !subscriptionType || paymentIntentId) {
    return res.status(400).json({ message: "All fields are required" });
  }

  try {
    const db = await connectDB();
    const applyRequestCollection = db.collection("registration_requests");
    const userCollection = db.collection("users");

    const user = await userCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const applyRequest = {
      user_id: new ObjectId(userId),
      garageName,
      garageLocation,
      subscriptionType,
      paymentIntentId,

      status: "pending",
      createdAt: new Date(),
    };

    await applyRequestCollection.insertOne(applyRequest);

    res.status(201).json({ message: "Application submitted successfully." });
  } catch (error) {
    console.error("Apply garage error:", error);
    res.status(500).json({ message: "Something went wrong", error });
  }
};
const getAllRequests = async (req, res) => {
  try {
    const db = await connectDB();
    const applyRequestCollection = db.collection("registration_requests");

    const requests = await applyRequestCollection
      .aggregate([
        {
          $lookup: {
            from: "users",
            localField: "user_id",
            foreignField: "_id",
            as: "userInfo",
          },
        },
        {
          $unwind: "$userInfo",
        },
        {
          $sort: { createdAt: -1 },
        },

        {
          $project: {
            garageName: 1,
            garageLocation: 1,
            subscriptionType: 1,
            status: 1,
            createdAt: 1,
            "userInfo.name": 1,
            "userInfo.email": 1,
            "userInfo.phoneNumber": 1,
          },
        },
      ])
      .toArray();

    res.status(200).json({ requests });
  } catch (error) {
    console.error("Get all requests error:", error);
    res.status(500).json({ message: "Something went wrong", error });
  }
};

const updateRequestStatus = async (req, res) => {
  const { requestId } = req.params;
  const { status } = req.body;

  if (!requestId || !status) {
    return res.status(400).json({ message: "Missing requestId or status" });
  }

  try {
    const db = await connectDB();
    const requestCollection = db.collection("registration_requests");
    const usersCollection = db.collection("users");
    const garageCollection = db.collection("garages");
    const ownersCollection = db.collection("owners");

    const request = await requestCollection.findOne({
      _id: new ObjectId(requestId),
    });
    if (!request) {
      return res.status(404).json({ message: "Request not found" });
    }

    // لو الحالة accepted لازم نتحقق من الدفع أولًا
    // if (status === "accepted") {
    //   const paymentIntentId = request.paymentIntentId;
    //   if (!paymentIntentId) {
    //     return res
    //       .status(400)
    //       .json({ message: "No payment intent found for this request" });
    //   }

    //   // جلب حالة الدفع من Stripe
    //   const paymentIntent = await stripe.paymentIntents.retrieve(
    //     paymentIntentId
    //   );

    //   if (paymentIntent.status !== "succeeded") {
    //     return res
    //       .status(400)
    //       .json({ message: "Payment not completed or failed" });
    //   }
    // }

    // تحديث حالة الطلب
    await requestCollection.updateOne(
      { _id: new ObjectId(requestId) },
      { $set: { status } }
    );

    // إذا تم القبول و الدفع ناجح، ننشئ المالك والكراج
    if (status === "accepted") {
      const userId = request.user_id;

      await usersCollection.updateOne(
        { _id: new ObjectId(userId) },
        { $set: { role: "owner" } }
      );

      const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

      const newOwnerData = {
        _id: new ObjectId(userId),
        name: user.name,
        email: user.email,
        garage_id: "",
      };

      const ownerInsertResult = await ownersCollection.insertOne(newOwnerData);

      let subscriptionDurationDays;
      switch (request.subscriptionType) {
        case "6month":
          subscriptionDurationDays = 180;
          break;
        case "1year":
          subscriptionDurationDays = 365;
          break;
        case "trial":
        default:
          subscriptionDurationDays = 14;
          break;
      }

      const subscriptionStartDate = new Date();
      const subscriptionEndDate = new Date(subscriptionStartDate);
      subscriptionEndDate.setDate(
        subscriptionEndDate.getDate() + subscriptionDurationDays
      );

      const now = new Date();
      const garageStatus = now <= subscriptionEndDate ? "active" : "expired";

      const costMap = {
        trial: 0,
        "6month": 60,
        "1year": 100,
      };
      const cost = costMap[request.subscriptionType] ?? 0;

      const newGarage = {
        name: request.garageName,
        location: request.garageLocation,
        cost,
        status: garageStatus,
        subscriptionStartDate,
        subscriptionEndDate,
        owner_id: ownerInsertResult.insertedId,
        createdAt: new Date(),
      };

      const garageInsertResult = await garageCollection.insertOne(newGarage);
      await ownersCollection.updateOne(
        { _id: new ObjectId(userId) },
        { $set: { garage_id: garageInsertResult.insertedId } }
      );
    }

    res.status(200).json({ message: "Status updated successfully" });
  } catch (error) {
    console.error("Update request status error:", error);
    res.status(500).json({ message: "Something went wrong", error });
  }
};

module.exports = {
  applyGarage,
  getAllRequests,
  updateRequestStatus,
};
