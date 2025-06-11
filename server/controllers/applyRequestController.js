const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");
// const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY); // تأكد من ضبط مفتاح Stripe في env
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "deyaanoor9@gmail.com",
    pass: "mzfc rxnn zeez tmxr",
  },
});

const applyGarage = async (req, res) => {
  const { garageName, garageLocation, subscriptionType } =
    req.body;
  const userId = req.body.user_id;

  if (!garageName || !garageLocation || !subscriptionType ) {
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
    const plansCollection = db.collection("plans");

    const request = await requestCollection.findOne({
      _id: new ObjectId(requestId),
    });
    if (!request) {
      return res.status(404).json({ message: "Request not found" });
    }

    await requestCollection.updateOne(
      { _id: new ObjectId(requestId) },
      { $set: { status } }
    );

    // جلب بيانات المستخدم لإرسال الإيميل
    const user = await usersCollection.findOne({
      _id: new ObjectId(request.user_id),
    });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // نص الإيميل حسب الحالة
    let subject, html;
    if (status === "accepted") {
      subject = "Garage Registration Request Accepted";
      html = `
        <div style="font-family: Arial, sans-serif; background: #fff; border-radius: 8px; border: 1px solid #ffa500; padding: 24px; max-width: 500px; margin: auto;">
          <h2 style="color: #ffa500;">Congratulations!</h2>
          <p style="font-size: 16px; color: #333;">
            Dear ${user.name},<br><br>
            Your garage registration request <b>(${request.garageName})</b> has been <span style="color:green;font-weight:bold;">accepted</span>.<br>
            You can now log in and manage your garage as an owner.<br><br>
            Welcome to our platform!
          </p>
          <hr style="border:none;border-top:1px solid #eee;margin:24px 0;">
          <p style="font-size:12px;color:#888;text-align:center;">&copy; 2025 Mechanic Workshop Management</p>
        </div>
      `;
    } else if (status === "rejected") {
      subject = "Garage Registration Request Rejected";
      html = `
        <div style="font-family: Arial, sans-serif; background: #fff; border-radius: 8px; border: 1px solid #ffa500; padding: 24px; max-width: 500px; margin: auto;">
          <h2 style="color: #d32f2f;">We're Sorry!</h2>
          <p style="font-size: 16px; color: #333;">
            Dear ${user.name},<br><br>
            Unfortunately, your garage registration request <b>(${request.garageName})</b> has been <span style="color:#d32f2f;font-weight:bold;">rejected</span>.<br>
            If you have any questions, please contact our support team.<br><br>
            Thank you for your interest.
          </p>
          <hr style="border:none;border-top:1px solid #eee;margin:24px 0;">
          <p style="font-size:12px;color:#888;text-align:center;">&copy; 2025 Mechanic Workshop Management</p>
        </div>
      `;
    }

    // أرسل الإيميل فقط إذا كانت الحالة قبول أو رفض
    if (status === "accepted" || status === "rejected") {
      await transporter.sendMail({
        from: "deyaanoor9@gmail.com",
        to: user.email,
        subject,
        html,
      });
    }

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
      const plan = await plansCollection.findOne({
        name: request.subscriptionType,
      });
      if (!plan) {
        return res
          .status(404)
          .json({ message: "Plan not found for this subscriptionType" });
      }
      const planPrice = plan.price;
      const ownerInsertResult = await ownersCollection.insertOne(newOwnerData);

      let subscriptionDurationDays;
      switch (request.subscriptionType) {
        case "6months":
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

      const cost = planPrice;

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
const existRequest = async (req, res) => {
  try {
    const db = await connectDB();
    const { email } = req.params;
    const applyRequestCollection = db.collection("registration_requests");
    const userCollection = db.collection("users");

    console.log("قبل جلب المستخدم");
    const user = await userCollection.findOne({ email: email });
    console.log("بعد جلب المستخدم", user);

    if (!user) {
      return res
        .status(404)
        .json({ statusPending: false, message: "User not found" });
    }

    const existingRequest = await applyRequestCollection.findOne({
      user_id: new ObjectId(user._id),
    });

    console.log("بعد جلب الطلب", existingRequest);

    if (existingRequest) {
      if (existingRequest.status === "pending") {
        return res.status(200).json({ statusPending: true });
      } else {
        return res.status(200).json({ statusPending: false });
      }
    } else {
      return res.status(200).json({ statusPending: false });
    }
  } catch (error) {
    console.error("Exist request error:", error);
    res.status(500).json({ message: "Something went wrong", error });
  }
};
module.exports = {
  applyGarage,
  getAllRequests,
  updateRequestStatus,
  existRequest,
};
