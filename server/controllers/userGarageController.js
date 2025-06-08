const { ObjectId } = require('mongodb');
const connectDB = require('../config/db');

const getUserGarageData = async (req, res) => {
  const { userId } = req.params;

  try {
    const db = await connectDB();

    const ownersCollection = db.collection('owners');
    const garagesCollection = db.collection('garages');
    const registrationRequestsCollection = db.collection('registration_requests');

    const owner = await ownersCollection.findOne({ _id: new ObjectId(userId) });

    if (!owner) {
      return res.status(404).json({ message: 'المالك غير موجود' });
    }

    const garageId = owner.garage_id;

    const garage = await garagesCollection.findOne(
      { _id: new ObjectId(garageId) },
      {
        projection: {
          name: 1,
          cost: 1,
          subscriptionEndDate: 1,
          createdAt: 1,
        },
      }
    );

    if (!garage) {
      return res.status(404).json({ message: 'الكراج غير موجود' });
    }

    const acceptedRequest = await registrationRequestsCollection.findOne(
      {
        user_id: new ObjectId(userId),
        status: 'accepted',
      },
      {
        projection: { subscriptionType: 1 },
      }
    );

    if (!acceptedRequest) {
      return res.status(404).json({ message: 'لا يوجد اشتراك مقبول' });
    }

    const mergedData = {
      ...garage,
      subscriptionType: acceptedRequest.subscriptionType,
    };

    res.status(200).json(mergedData);

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'حدث خطأ أثناء جلب البيانات' });
  }
};

module.exports = { getUserGarageData };
