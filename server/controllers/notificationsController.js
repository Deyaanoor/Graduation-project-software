const connectDB = require("../config/db");
const { ObjectId } = require("mongodb");
const admin = require("../../firebase/firebase-config");
const moment = require("moment-timezone");

const createNotification = async (req, res) => {
  const palestineTime = moment.tz("Asia/Jerusalem").toDate();

  try {
    const {
      reportId,
      senderName,
      adminId,
      type = "report",
      newsId,
      newsTitle,
      newsbody,
      messageTitle,
      messageBody,
      garageId,
      requestTitle,
    } = req.body;
    console.log("🕒 Palestine as Date:", palestineTime); // يجب أن يكون بنفس وقت فلسطين

    if (!senderName || !adminId || !type) {
      return res
        .status(400)
        .json({ message: "senderName و adminId و type مطلوبة" });
    }

    if (!ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: "adminId غير صالح" });
    }

    const db = await connectDB();

    // 👤 البحث عن المستخدم وتحديد نوعه
    let userType = "";
    let user = await db
      .collection("employees")
      .findOne({ _id: new ObjectId(adminId) });
    if (user) userType = "employee";

    if (!user) {
      user = await db
        .collection("owners")
        .findOne({ _id: new ObjectId(adminId) });
      if (user) userType = "owner";
    }

    if (!user) {
      user = await db
        .collection("clients")
        .findOne({ _id: new ObjectId(adminId) });
      if (user) userType = "client";
    }
    if (!user) {
      user = await db
        .collection("registration_requests")
        .findOne({ user_id: new ObjectId(adminId) });
      if (user) userType = "";
    }

    if (!user) {
      return res
        .status(404)
        .json({ message: "الموظف أو المالك أو العميل غير موجود" });
    }

    // 🏠 تحديد الجراج
    let garage;

    if (userType === "client") {
      // ✅ تحويل garageId من String إلى ObjectId
      if (!garageId || !ObjectId.isValid(garageId)) {
        return res
          .status(400)
          .json({ message: "garageId غير صالح أو غير موجود للعميل" });
      }

      garage = await db
        .collection("garages")
        .findOne({ _id: new ObjectId(garageId) });
    } else {
      // 🔁 الطريقة القديمة للموظف أو المالك
      const garageQuery = user.garage_id
        ? { _id: user.garage_id }
        : { owner_id: user._id };

      garage = await db.collection("garages").findOne(garageQuery);
    }

    // 🔔 تجهيز الإشعار
    let notification;
    if (type === "report") {
      if (!reportId) {
        return res
          .status(400)
          .json({ message: "reportId مطلوب لإشعار التقرير" });
      }
      notification = {
        title: newsTitle,
        body: newsbody,
        reportId,
        type: "report",
        status: "pending",
        timestamp: palestineTime,
        isRead: false,
        garageId: garage._id,
        senderName,
      };
    } else if (type === "news") {
      if (!newsId || !newsTitle) {
        return res
          .status(400)
          .json({ message: "newsId و newsTitle مطلوبين لإشعار الأخبار" });
      }
      notification = {
        title: newsTitle,
        body: newsbody,
        newsId,
        type: "news",
        timestamp: palestineTime,
        isRead: false,
        garageId: garage._id,
        senderName,
      };
    } else if (type === "message") {
      if (!messageTitle || !messageBody) {
        return res
          .status(400)
          .json({ message: "newsId و newsTitle مطلوبين لإشعار الأخبار" });
      }
      notification = {
        title: messageTitle,
        body: messageBody,

        type: "message",
        timestamp: palestineTime,
        isRead: false,
        garageId: garage._id,
        senderName,
      };
    } else if (type === "request") {
      notification = {
        title: requestTitle,
        type: "request",
        timestamp: palestineTime,
        isRead: false,
        senderName,
      };
    } else {
      return res.status(400).json({ message: "نوع الإشعار غير مدعوم" });
    }

    // 💾 حفظ الإشعار
    const result = await db.collection("notifications").insertOne(notification);

    // 🎯 تحديد المستلمين
    let recipients = [];
    if (type === "news") {
      recipients = await db
        .collection("employees")
        .find({ garage_id: garage._id })
        .toArray();
    } else if (type === "report") {
      const owner = await db
        .collection("owners")
        .findOne({ _id: garage.owner_id });
      if (owner) recipients = [owner];
    } else if (type === "message") {
      const owner = await db
        .collection("owners")
        .findOne({ _id: garage.owner_id });
      if (owner) recipients = [owner];
    } else if (type === "request") {
      const admin = await db.collection("users").findOne({ role: "admin" });
      if (admin) recipients = [admin];
    }

    // 📡 جلب التوكنات من جدول users
    const recipientEmails = recipients.map((r) => r.email).filter(Boolean);
    const usersWithTokens = await db
      .collection("users")
      .find({
        email: { $in: recipientEmails },
        fcmToken: { $exists: true, $ne: null },
      })
      .toArray();

    const tokens = usersWithTokens.flatMap((u) =>
      u.fcmToken.split(/\s+/).filter(Boolean)
    );
    console.log("Server time:", new Date().toISOString());

    console.log("📱 Tokens:", tokens);

    console.log("Server local time:", new Date().toString());
    console.log("Server UTC time:", new Date().toUTCString());
    if (tokens.length > 0) {
      const response = await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: notification.title,
          body: notification.body,
        },
      });

      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(
            `❌ فشل إرسال الإشعار للتوكن ${tokens[idx]}:`,
            resp.error
          );
        } else {
          console.log(`✅ تم الإرسال بنجاح للتوكن ${tokens[idx]}`);
        }
      });

      console.log("📡 Notification test response:", response);
    }

    res.status(201).json({
      message: "Successfully created notification",
      insertedId: result.insertedId,
      data: notification,
    });
  } catch (error) {
    console.error("❌ Error creating notification:", error);
    res.status(500).json({ message: "حدث خطأ أثناء إرسال الإشعار" });
  }
};

const getNotifications = async (req, res) => {
  try {
    const adminId = req.params.adminId;

    if (!adminId || !ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: "adminId غير صالح" });
    }

    const db = await connectDB();

    // 1. جرب كموظف
    let user = await db
      .collection("employees")
      .findOne({ _id: new ObjectId(adminId) });
    let typeToFetch = ["news"];
    let garageQuery;

    if (user) {
      // موظف، نأخذ garage_id من عنده
      if (!user.garage_id) {
        return res.status(404).json({ message: "الموظف غير مرتبط بجراج" });
      }
      garageQuery = { _id: user.garage_id };
    } else {
      // 2. جرب كمالك
      user = await db
        .collection("owners")
        .findOne({ _id: new ObjectId(adminId) });
      if (user) {
        typeToFetch = ["report", "message"];
        garageQuery = { owner_id: user._id };
      } else {
        // 3. جرب كأدمن في users
        user = await db
          .collection("users")
          .findOne({ _id: new ObjectId(adminId), role: "admin" });
        if (user) {
          // الأدمن يرى فقط إشعارات الطلبات (request)
          const notifications = await db
            .collection("notifications")
            .find({ type: "request" })
            .toArray();
          return res.status(200).json({ notifications });
        } else {
          return res
            .status(404)
            .json({ message: "الموظف أو المالك أو الأدمن غير موجود" });
        }
      }
    }

    // إذا وصلنا هنا، المستخدم موظف أو مالك
    const garage = await db.collection("garages").findOne(garageQuery);
    if (!garage) {
      return res
        .status(404)
        .json({ message: "لا يوجد جراج مرتبط بهذا المستخدم" });
    }

    const notificationsCollection = db.collection("notifications");
    const notifications = await notificationsCollection
      .find({
        garageId: garage._id,
        type: { $in: typeToFetch },
      })
      .toArray();

    res.status(200).json({ notifications });
  } catch (error) {
    console.error("❌ Error fetching notifications:", error);
    res.status(500).json({ message: "حدث خطأ أثناء جلب الإشعارات" });
  }
};

// تحديث الإشعار كـ "مقروء"
const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;

    if (!notificationId || !ObjectId.isValid(notificationId)) {
      return res.status(400).json({ message: "notificationId غير صالح" });
    }

    const db = await connectDB();
    const notificationsCollection = db.collection("notifications");

    const result = await notificationsCollection.updateOne(
      { _id: new ObjectId(notificationId) },
      { $set: { isRead: true } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: "الإشعار غير موجود" });
    }

    res.status(200).json({ message: 'تم تحديث الإشعار إلى "تمت قراءته"' });
  } catch (error) {
    console.error("❌ Error marking notification as read:", error);
    res.status(500).json({ message: "حدث خطأ أثناء تحديث حالة الإشعار" });
  }
};

// حذف إشعار
const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;

    if (!notificationId || !ObjectId.isValid(notificationId)) {
      return res.status(400).json({ message: "notificationId غير صالح" });
    }

    const db = await connectDB();
    const notificationsCollection = db.collection("notifications");

    const result = await notificationsCollection.deleteOne({
      _id: new ObjectId(notificationId),
    });

    if (result.deletedCount === 0) {
      return res
        .status(404)
        .json({ message: "الإشعار غير موجود أو لم يتم حذفه" });
    }

    res.status(200).json({ message: "تم حذف الإشعار بنجاح" });
  } catch (error) {
    console.error("❌ Error deleting notification:", error);
    res.status(500).json({ message: "حدث خطأ أثناء حذف الإشعار" });
  }
};

const countUnreadNotifications = async (req, res) => {
  try {
    const { adminId } = req.params;

    if (!adminId || !ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: "adminId غير صالح" });
    }

    const db = await connectDB();

    // جرب كموظف
    let user = await db
      .collection("employees")
      .findOne({ _id: new ObjectId(adminId) });
    let typeToFetch = ["news"];
    let garageQuery;

    if (user) {
      if (!user.garage_id) {
        return res.status(404).json({ message: "الموظف غير مرتبط بجراج" });
      }
      garageQuery = { _id: user.garage_id };
    } else {
      // جرب كمالك
      user = await db
        .collection("owners")
        .findOne({ _id: new ObjectId(adminId) });
      if (user) {
        typeToFetch = ["report", "message"];
        garageQuery = { owner_id: user._id };
      } else {
        // جرب كأدمن
        user = await db
          .collection("users")
          .findOne({ _id: new ObjectId(adminId), role: "admin" });
        if (user) {
          // الأدمن: عد الإشعارات غير المقروءة من نوع request فقط
          const count = await db.collection("notifications").countDocuments({
            type: "request",
            isRead: false,
          });
          return res.status(200).json({ unreadCount: count });
        } else {
          return res
            .status(404)
            .json({ message: "الموظف أو المالك أو الأدمن غير موجود" });
        }
      }
    }

    // إذا وصلنا هنا، المستخدم موظف أو مالك
    const garage = await db.collection("garages").findOne(garageQuery);
    if (!garage) {
      return res
        .status(404)
        .json({ message: "لا يوجد جراج مرتبط بهذا المستخدم" });
    }

    const count = await db.collection("notifications").countDocuments({
      garageId: garage._id,
      isRead: false,
      type: { $in: typeToFetch },
    });

    res.status(200).json({ unreadCount: count });
  } catch (error) {
    console.error("❌ Error counting unread notifications:", error);
    res.status(500).json({ message: "حدث خطأ أثناء حساب عدد الإشعارات" });
  }
};

module.exports = {
  createNotification,
  getNotifications,
  markAsRead,
  deleteNotification,
  countUnreadNotifications,
};
