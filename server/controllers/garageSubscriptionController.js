const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");

const activateGarageSubscription = async (req, res) => {
  const { userId } = req.params;
  const { subscriptionType } = req.body;

  if (!userId || !subscriptionType) {
    return res
      .status(400)
      .json({ message: "Missing userId or subscriptionType" });
  }

  try {
    const db = await connectDB();
    const garageCollection = db.collection("garages");
    const requestCollection = db.collection("registration_requests");
    const plansCollection = db.collection("plans");

    // التحقق من وجود الكراج
    const garage = await garageCollection.findOne({
      owner_id: new ObjectId(userId),
    });
    if (!garage) {
      return res
        .status(404)
        .json({ message: "Garage not found for this user" });
    }

    // التحقق من وجود الطلب
    const request = await requestCollection.findOne({
      user_id: new ObjectId(userId),
    });
    if (!request) {
      return res
        .status(404)
        .json({ message: "Registration request not found for this user" });
    }

    // جلب السعر من جدول الخطط
    const plan = await plansCollection.findOne({ name: subscriptionType });
    if (!plan) {
      return res
        .status(404)
        .json({ message: "Plan not found for this subscriptionType" });
    }
    const cost = plan.price;

    // تحديث نوع الاشتراك في طلب التسجيل
    await requestCollection.updateOne(
      { user_id: new ObjectId(userId) },
      { $set: { subscriptionType } }
    );

    // تحديد مدة الاشتراك
    let subscriptionDurationDays;
    switch (subscriptionType) {
      case "6months":
        subscriptionDurationDays = 180;
        break;
      case "1year":
        subscriptionDurationDays = 365;
        break;
      default:
        subscriptionDurationDays = 14;
        break;
    }
    const now = new Date();

    const subscriptionEndDate = new Date(garage.subscriptionEndDate);
    subscriptionEndDate.setDate(
      subscriptionEndDate.getDate() + subscriptionDurationDays
    );

    const status = now <= subscriptionEndDate ? "active" : "expired";

    // تحديث الكراج مع الكلفة
    await garageCollection.updateOne(
      { owner_id: new ObjectId(userId) },
      {
        $set: {
          subscriptionStartDate: now,
          subscriptionEndDate,
          status,
        },
        $inc: {
          cost: planPrice, // ← هذا يضيف قيمة الخطة إلى القيمة الحالية
        },
      }
    );

    res.status(200).json({ message: "Subscription activated successfully" });
  } catch (error) {
    console.error("Activate garage subscription error:", error);
    res.status(500).json({ message: "Something went wrong", error });
  }
};

module.exports = {
  activateGarageSubscription,
};
