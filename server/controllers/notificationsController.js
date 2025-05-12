const connectDB = require('../config/db');
const { ObjectId } = require('mongodb');

const createNotification = async (req, res) => {
  try {
    const { reportId, senderName, adminId, type = 'report', newsId, newsTitle } = req.body;

    if (!senderName || !adminId || !type) {
      return res.status(400).json({ message: 'senderName و adminId و type مطلوبة' });
    }

    if (!ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: 'adminId غير صالح' });
    }

    const db = await connectDB();
    let user = await db.collection('employees').findOne({ _id: new ObjectId(adminId) });
    if (!user) {
      user = await db.collection('owners').findOne({ _id: new ObjectId(adminId) });
    }
    if (!user) {
      return res.status(404).json({ message: 'الموظف أو صاحب الجراج غير موجود' });
    }

    const garageQuery = user.garage_id
      ? { _id: user.garage_id }
      : { owner_id: user._id };

    const garage = await db.collection('garages').findOne(garageQuery);

    if (!garage) {
      return res.status(404).json({ message: 'لا يوجد جراج مرتبط بهذا المستخدم' });
    }

    const notificationsCollection = db.collection('notifications');
    let notification;

    if (type === 'report') {
      if (!reportId) {
        return res.status(400).json({ message: 'reportId مطلوب لإشعار التقرير' });
      }

      notification = {
        title: 'تقرير جديد',
        body: `تم إرسال تقرير من قبل ${senderName}`,
        reportId,
        type: 'report',
        status: 'pending',
        timestamp: new Date(),
        isRead: false,
        garageId: garage._id,
        senderName,
      };
    } else if (type === 'news') {
      if (!newsId || !newsTitle) {
        return res.status(400).json({ message: 'newsId و newsTitle مطلوبين لإشعار الأخبار' });
      }

      notification = {
        title: 'خبر جديد',
        body: `تم نشر خبر: ${newsTitle}`,
        newsId,
        type: 'news',
        timestamp: new Date(),
        isRead: false,
        garageId: garage._id,
        senderName,
      };
    } else {
      return res.status(400).json({ message: 'نوع الإشعار غير مدعوم' });
    }

    const result = await notificationsCollection.insertOne(notification);

    res.status(201).json({
      message: 'تم إرسال الإشعار بنجاح',
      newsId: result.insertedId, 
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

    const db = await connectDB();

    // نحاول نلاقيه أولًا بالموظفين
    let user = await db.collection('employees').findOne({ _id: new ObjectId(adminId) });
    let typeToFetch = 'news';
    let garageQuery;

    if (user) {
      // موظف، نأخذ garage_id من عنده
      if (!user.garage_id) {
        return res.status(404).json({ message: 'الموظف غير مرتبط بجراج' });
      }
      garageQuery = { _id: user.garage_id };
    } else {
      // مش موظف، نحاول نلاقيه كـ owner
      user = await db.collection('owners').findOne({ _id: new ObjectId(adminId) });
      if (!user) {
        return res.status(404).json({ message: 'الموظف أو المالك غير موجود' });
      }
      typeToFetch = 'report';
      garageQuery = { owner_id: user._id };
    }

    const garage = await db.collection('garages').findOne(garageQuery);
    if (!garage) {
      return res.status(404).json({ message: 'لا يوجد جراج مرتبط بهذا المستخدم' });
    }

    const notificationsCollection = db.collection('notifications');
    const notifications = await notificationsCollection.find({
      garageId: garage._id,
      type: typeToFetch
    }).toArray();

    res.status(200).json({ notifications });
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

const countUnreadNotifications = async (req, res) => {
  try {
    const { adminId } = req.params;

    if (!adminId || !ObjectId.isValid(adminId)) {
      return res.status(400).json({ message: 'adminId غير صالح' });
    }

    const db = await connectDB();

    let user = await db.collection('employees').findOne({ _id: new ObjectId(adminId) });
    let typeToFetch = 'news';
    let garageQuery;

    if (user) {
      if (!user.garage_id) {
        return res.status(404).json({ message: 'الموظف غير مرتبط بجراج' });
      }
      garageQuery = { _id: user.garage_id };
    } else {
      user = await db.collection('owners').findOne({ _id: new ObjectId(adminId) });
      if (!user) {
        return res.status(404).json({ message: 'الموظف أو المالك غير موجود' });
      }
      typeToFetch = 'report';
      garageQuery = { owner_id: user._id };
    }

    const garage = await db.collection('garages').findOne(garageQuery);
    if (!garage) {
      return res.status(404).json({ message: 'لا يوجد جراج مرتبط بهذا المستخدم' });
    }

    const count = await db.collection('notifications').countDocuments({
      garageId: garage._id,
      isRead: false,
      type: typeToFetch
    });

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
