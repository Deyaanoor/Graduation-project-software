const connectDB = require('../config/db');
const { ObjectId } = require('mongodb');

// إنشاء إشعار جديد
const createNotification = async (req, res) => {
  try {
    const { reportId, senderName, adminId } = req.body;

    if (!reportId || !senderName || !adminId) {
      return res.status(400).json({ message: 'reportId و senderName و adminId مطلوبة' });
    }

    if (!ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: 'adminId غير صالح' });
    }

    const db = await connectDB();
    const employee = await db.collection('employees').findOne({ _id: new ObjectId(adminId) });

    if (!employee) {
      return res.status(404).json({ message: 'الموظف غير موجود' });
    }

    const garage = await db.collection('garages').findOne({ _id: employee.garage_id });
    const garageId = garage ? garage._id : null;

    if (!garageId) {
      return res.status(404).json({ message: 'لا يوجد جراج مرتبط بهذا الموظف' });
    }

    const notificationsCollection = db.collection('notifications');
    const notification = {
      title: 'تقرير جديد',
      body: `تم إرسال تقرير من قبل ${senderName}`,
      reportId,
      status: 'pending',
      timestamp: new Date(),
      isRead: false,
      garageId,
      senderName,
    };

    await notificationsCollection.insertOne(notification);

    res.status(201).json({
      message: 'تم إرسال الإشعار بنجاح',
      data: notification,
    });

  } catch (error) {
    console.error("❌ Error creating notification:", error);
    res.status(500).json({ message: 'حدث خطأ أثناء إرسال الإشعار' });
  }
};

const getNotifications = async (req, res) => {
  try {
    const adminId = req.params.adminId;

    if (!adminId || !ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: 'adminId غير صالح' });
    }
    console.log("adminId:", adminId);
    const db = await connectDB();
    const owner = await db.collection('owners').findOne({ _id: new ObjectId(adminId) });

    if (!owner) {
      return res.status(404).json({ message: 'المالك غير موجود' });
    }

    const garage = await db.collection('garages').findOne({ owner_id: owner._id });
    const garageId = garage ? garage._id : null;

    if (!garageId) {
      return res.status(404).json({ message: 'لا يوجد جراج مرتبط بهذا المالك' });
    }

    const notificationsCollection = db.collection('notifications');
    const notifications = await notificationsCollection.find({ garageId }).toArray();

    res.status(200).json({ notifications });
    console.log("Notifications:", notifications);
  } catch (error) {
    console.error("❌ Error fetching notifications:", error);
    res.status(500).json({ message: 'حدث خطأ أثناء جلب الإشعارات' });
  }
};

// تحديث الإشعار كـ "مقروء"
const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;

    if (!notificationId || !ObjectId.isValid(notificationId)) {
      return res.status(400).json({ message: 'notificationId غير صالح' });
    }

    const db = await connectDB();
    const notificationsCollection = db.collection('notifications');

    const result = await notificationsCollection.updateOne(
      { _id: new ObjectId(notificationId) },
      { $set: { isRead: true } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: 'الإشعار غير موجود' });
    }

    res.status(200).json({ message: 'تم تحديث الإشعار إلى "تمت قراءته"' });

  } catch (error) {
    console.error("❌ Error marking notification as read:", error);
    res.status(500).json({ message: 'حدث خطأ أثناء تحديث حالة الإشعار' });
  }
};

// حذف إشعار
const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;

    if (!notificationId || !ObjectId.isValid(notificationId)) {
      return res.status(400).json({ message: 'notificationId غير صالح' });
    }

    const db = await connectDB();
    const notificationsCollection = db.collection('notifications');

    const result = await notificationsCollection.deleteOne({ _id: new ObjectId(notificationId) });

    if (result.deletedCount === 0) {
      return res.status(404).json({ message: 'الإشعار غير موجود أو لم يتم حذفه' });
    }

    res.status(200).json({ message: 'تم حذف الإشعار بنجاح' });

  } catch (error) {
    console.error("❌ Error deleting notification:", error);
    res.status(500).json({ message: 'حدث خطأ أثناء حذف الإشعار' });
  }
};

// عد الإشعارات الغير مقروءة
const countUnreadNotifications = async (req, res) => {
  try {
    const { adminId } = req.params;

    if (!adminId || !ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: 'adminId غير صالح' });
    }

    const db = await connectDB();
    const owner = await db.collection('owners').findOne({ _id: new ObjectId(adminId) });

    if (!owner) {
      return res.status(404).json({ message: 'المالك غير موجود' });
    }

    const garage = await db.collection('garages').findOne({ owner_id: owner._id });
    const garageId = garage ? garage._id : null;

    if (!garageId) {
      return res.status(404).json({ message: 'لا يوجد جراج مرتبط بهذا المالك' });
    }

    const notificationsCollection = db.collection('notifications');
    const count = await notificationsCollection.countDocuments({ garageId, isRead: false });

    res.status(200).json({ unreadCount: count });

  } catch (error) {
    console.error("❌ Error counting unread notifications:", error);
    res.status(500).json({ message: 'حدث خطأ أثناء حساب عدد الإشعارات' });
  }
};

module.exports = {
  createNotification,
  getNotifications,
  markAsRead,
  deleteNotification,
  countUnreadNotifications
};
