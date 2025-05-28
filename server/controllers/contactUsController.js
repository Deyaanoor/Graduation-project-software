const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");

const ADMIN_ID = "5f6f5b7b3e9a1b1c8cd7d2a2"; // معرّف المسؤول، يمكن تغييره حسب الحاجة

// إضافة مشكلة تواصل جديدة بناءً على userId
const addContactMessage = async (req, res) => {
  try {
    const { userId, type, message } = req.body; // إضافة userId في الـ body

    const db = await connectDB();
    const contactMessagesCollection = db.collection("contact_messages");
    const userCollection = db.collection("users"); // تغيير collection إلى 'users'

    // التحقق من وجود المستخدم باستخدام userId
    let user = await userCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const newMessage = {
      type,
      message,
      status: "pending", // الحالة المبدئية للمشكلة
      user_id: new ObjectId(user._id), // ربط المشكلة بالمستخدم
      admin_id: new ObjectId(ADMIN_ID),
    };

    const messageResult = await contactMessagesCollection.insertOne(newMessage);

    // ✅ تحديث سجل المستخدم وإضافة contact_message_ids
    await userCollection.updateOne(
      { _id: user._id },
      { $push: { contact_message_ids: messageResult.insertedId } }
    );

    res.status(201).json({
      message: "Message added successfully",
      data: {
        ...newMessage,
        _id: messageResult.insertedId,
      },
    });
  } catch (error) {
    console.error("❌ Error adding message:", error);
    res
      .status(500)
      .json({ message: "An error occurred while adding the message" });
  }
};

// جلب جميع الرسائل المرتبطة بمستخدم معين
const getContactMessagesByUserId = async (req, res) => {
  try {
    const { userId } = req.params; // استخدم userId من المعاملات

    const db = await connectDB();
    const contactMessagesCollection = db.collection("contact_messages");

    const messages = await contactMessagesCollection
      .find({ user_id: new ObjectId(userId) })
      .toArray(); // جلب الرسائل بناءً على userId
    res.status(200).json(messages);
  } catch (error) {
    console.error("❌ Error fetching messages:", error);
    res
      .status(500)
      .json({ message: "An error occurred while fetching messages" });
  }
};

const getContactMessages = async (req, res) => {
  try {
    const db = await connectDB();
    const contactMessagesCollection = db.collection("contact_messages");

    const messages = await contactMessagesCollection
      .aggregate([
        {
          $lookup: {
            from: "users",
            localField: "user_id",
            foreignField: "_id",
            as: "user",
          },
        },
        {
          $unwind: "$user",
        },
        {
          $project: {
            _id: 1,
            type: 1,
            message: 1,
            status: 1,
            user_id: 1,
            userName: "$user.name",
            userEmail: "$user.email",
            userPhone: "$user.phoneNumber",
          },
        },
      ])
      .toArray();

    res.status(200).json(messages);
  } catch (error) {
    console.error("❌ Error fetching messages with user data:", error);
    res.status(500).json({
      message: "An error occurred while fetching messages with user data",
    });
  }
};

// تحديث حالة المشكلة بناءً على ID
const updateContactMessageStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    console.log("🔧 Status received:", status);

    const db = await connectDB();
    const contactMessagesCollection = db.collection("contact_messages");

    const message = await contactMessagesCollection.findOne({
      _id: new ObjectId(id),
    });
    if (!message) {
      return res.status(404).json({ message: "Message not found" });
    }

    const result = await contactMessagesCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: { status } }
    );

    console.log("🔄 Update result:", result);

    res.status(200).json({ message: "Message status updated successfully" });
  } catch (error) {
    console.error("❌ Error updating message status:", error);
    res
      .status(500)
      .json({ message: "An error occurred while updating the message status" });
  }
};

// حذف رسالة بناءً على ID
const deleteContactMessage = async (req, res) => {
  try {
    const { id } = req.params;

    const db = await connectDB();
    const contactMessagesCollection = db.collection("contact_messages");
    const userCollection = db.collection("users");

    const message = await contactMessagesCollection.findOne({
      _id: new ObjectId(id),
    });
    if (!message) {
      return res.status(404).json({ message: "Message not found" });
    }

    // جلب المستخدم المرتبط بالرسالة
    const user = await userCollection.findOne({
      _id: new ObjectId(message.user_id),
    });
    const userEmail = user?.email;

    // إزالة الـ message من قائمة المستخدم
    await userCollection.updateOne(
      { _id: user._id },
      { $pull: { contact_message_ids: new ObjectId(id) } }
    );

    // حذف الرسالة
    await contactMessagesCollection.deleteOne({ _id: new ObjectId(id) });

    res.status(200).json({ message: "Message deleted successfully" });
  } catch (error) {
    console.error("❌ Error deleting message:", error);
    res
      .status(500)
      .json({ message: "An error occurred while deleting the message" });
  }
};

module.exports = {
  addContactMessage,
  getContactMessages,
  getContactMessagesByUserId,
  deleteContactMessage,
  updateContactMessageStatus,
};
