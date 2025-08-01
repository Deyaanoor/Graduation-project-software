const connectDB = require("../config/db");
const { ObjectId } = require("mongodb");

const ADMIN_ID = "5f6f5b7b3e9a1b1c8cd7d2a2";

const addGarage = async (req, res) => {
  try {
    const { name, location, ownerName, ownerEmail, cost } = req.body;

    const db = await connectDB();
    const garagesCollection = db.collection("garages");
    const ownerCollection = db.collection("owners");

    let owner = await ownerCollection.findOne({ email: ownerEmail });
    if (!owner) {
      const newOwner = {
        name: ownerName,
        email: ownerEmail,
      };
      const result = await ownerCollection.insertOne(newOwner);
      owner = {
        _id: result.insertedId,
        ...newOwner,
      };
    }

    const newGarage = {
      name,
      location,
      ownerName,
      ownerEmail,
      cost,
      admin_id: new ObjectId(ADMIN_ID),
      owner_id: new ObjectId(owner._id),
    };

    const garageResult = await garagesCollection.insertOne(newGarage);

    // ✅ تحديث سجل الـ owner وإضافة garage_id
    await ownerCollection.updateOne(
      { _id: owner._id },
      { $set: { garage_id: garageResult.insertedId } }
    );

    res.status(201).json({
      message: "Garage added successfully",
      data: {
        ...newGarage,
        _id: garageResult.insertedId,
      },
    });
  } catch (error) {
    console.error("❌ Error adding garage:", error);
    res
      .status(500)
      .json({ message: "An error occurred while adding the garage" });
  }
};

const getGarages = async (req, res) => {
  try {
    const db = await connectDB();
    const garagesCollection = db.collection("garages");

    const garages = await garagesCollection
      .aggregate([
        {
          $addFields: {
            // تحويل owner_id من string إلى ObjectId
            ownerObjectId: { $toObjectId: "$owner_id" },
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "ownerObjectId", // استخدام الحقل المحول
            foreignField: "_id",
            as: "ownerDetails",
          },
        },
        {
          $unwind: {
            path: "$ownerDetails",
            preserveNullAndEmptyArrays: true, // للسماح بالجراجات بدون مالكين
          },
        },
        {
          $project: {
            _id: 1,
            name: 1,
            location: 1,
            status: 1,
            cost: 1,
            subscriptionStartDate: 1,
            subscriptionEndDate: 1,
            ownerName: "$ownerDetails.name",
            ownerEmail: "$ownerDetails.email",
            ownerPhone: "$ownerDetails.phoneNumber", // لاحظ أن الحقل في users هو phoneNumber وليس phone
            ownerAvatar: "$ownerDetails.avatar",
          },
        },
      ])
      .toArray();

    console.log(
      "Garages with owner details:",
      JSON.stringify(garages, null, 2)
    );
    res.status(200).json(garages);
  } catch (error) {
    console.error("❌ Error fetching garages:", error);
    res.status(500).json({
      message: "An error occurred while fetching garages",
      error: error.message,
    });
  }
};

const getGarageById = async (req, res) => {
  try {
    const { id } = req.params; // الحصول على الـ ID من مسار الطلب
    const db = await connectDB();
    const garagesCollection = db.collection("garages");

    // التحقق من أن الـ ID صالح
    if (!ObjectId.isValid(id)) {
      return res.status(400).json({ message: "Invalid garage ID" });
    }

    const garage = await garagesCollection
      .aggregate([
        {
          $match: { _id: new ObjectId(id) }, // تصفية حسب الـ ID المطلوب
        },
        {
          $addFields: {
            ownerObjectId: { $toObjectId: "$owner_id" },
          },
        },
        {
          $lookup: {
            from: "users",
            localField: "ownerObjectId",
            foreignField: "_id",
            as: "ownerDetails",
          },
        },
        {
          $unwind: {
            path: "$ownerDetails",
            preserveNullAndEmptyArrays: true,
          },
        },
        {
          $project: {
            _id: 1,
            name: 1,
            location: 1,
            status: 1,
            cost: 1,
            subscriptionStartDate: 1,
            subscriptionEndDate: 1,
            createdAt: 1,
            owner: {
              $cond: {
                if: { $ifNull: ["$ownerDetails", false] },
                then: {
                  _id: "$ownerDetails._id",
                  name: "$ownerDetails.name",
                  email: "$ownerDetails.email",
                  phoneNumber: "$ownerDetails.phoneNumber",
                  role: "$ownerDetails.role",
                  avatar: "$ownerDetails.avatar",
                  isVerified: "$ownerDetails.isVerified",
                },
                else: null,
              },
            },
          },
        },
      ])
      .next(); // استخدام next() بدلاً من toArray() لاسترجاع وثيقة واحدة

    if (!garage) {
      return res.status(404).json({ message: "Garage not found" });
    }

    console.log("Garage details:", JSON.stringify(garage, null, 2));
    res.status(200).json(garage);
  } catch (error) {
    console.error("❌ Error fetching garage:", error);
    res.status(500).json({
      message: "An error occurred while fetching the garage",
      error: error.message,
    });
  }
};

const deleteGarage = async (req, res) => {
  try {
    const { id } = req.params;

    const db = await connectDB();
    const garagesCollection = db.collection("garages");
    const ownerCollection = db.collection("owners");
    const reportsCollection = db.collection("reports");
    const notificationsCollection = db.collection("notifications");
    const employeesCollection = db.collection("employees");
    const usersCollection = db.collection("users");

    const garage = await garagesCollection.findOne({ _id: new ObjectId(id) });
    if (!garage) {
      return res.status(404).json({ message: "Garage not found" });
    }

    const owner = await ownerCollection.findOne({
      _id: new ObjectId(garage.owner_id),
    });
    const ownerEmail = owner?.email;
    const employees = await employeesCollection
      .find({ garageId: new ObjectId(id) })
      .toArray();
    const employeeEmails = employees.map((emp) => emp.email);
    const allEmailsToDelete = [ownerEmail, ...employeeEmails];

    if (allEmailsToDelete.length > 0) {
      await usersCollection.deleteMany({
        email: { $in: allEmailsToDelete },
      });
    }
    if (ownerEmail) {
      await usersCollection.deleteOne({ email: ownerEmail });
    }
    await reportsCollection.deleteMany({ garageId: new ObjectId(id) });
    await notificationsCollection.deleteMany({ garageId: new ObjectId(id) });
    await employeesCollection.deleteMany({ garageId: new ObjectId(id) });
    await ownerCollection.deleteOne({ _id: new ObjectId(garage.owner_id) });
    await garagesCollection.deleteOne({ _id: new ObjectId(id) });

    res
      .status(200)
      .json({ message: "Garage and related data deleted successfully" });
  } catch (error) {
    console.error("❌ Error deleting garage:", error);
    res
      .status(500)
      .json({ message: "An error occurred while deleting the garage" });
  }
};

const updateGarage = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, location, ownerName, ownerEmail, cost } = req.body;

    const db = await connectDB();
    const garagesCollection = db.collection("garages");
    const ownerCollection = db.collection("owners");
    const usersCollection = db.collection("users");

    const garage = await garagesCollection.findOne({ _id: new ObjectId(id) });
    if (!garage) {
      return res.status(404).json({ message: "Garage not found" });
    }
    const owner = await ownerCollection.findOne({
      _id: new ObjectId(garage.owner_id),
    });
    if (!owner) {
      return res.status(404).json({ message: "Owner not found" });
    }
    const oldOwnerEmail = owner.email;

    await usersCollection.updateOne(
      { email: oldOwnerEmail },
      { $set: { email: ownerEmail, name: ownerName } }
    );
    await ownerCollection.updateOne(
      { _id: new ObjectId(owner._id) },
      { $set: { name: ownerName, email: ownerEmail } }
    );
    await garagesCollection.updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          name,
          location,
          cost,
          ownerName,
          ownerEmail,
        },
      }
    );

    res
      .status(200)
      .json({ message: "Garage and related owner/user updated successfully" });
  } catch (error) {
    console.error("❌ Error updating garage:", error);
    res
      .status(500)
      .json({ message: "An error occurred while updating the garage" });
  }
};
const updateGarageStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!["Active", "Inactive"].includes(status)) {
      return res.status(400).json({ message: "Invalid status value" });
    }

    const db = await connectDB();
    const garagesCollection = db.collection("garages");

    const garage = await garagesCollection.findOne({ _id: new ObjectId(id) });
    if (!garage) {
      return res.status(404).json({ message: "Garage not found" });
    }

    await garagesCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: { status } }
    );

    res.status(200).json({ message: "Garage status updated successfully" });
  } catch (error) {
    console.error("❌ Error updating garage status:", error);
    res
      .status(500)
      .json({ message: "An error occurred while updating garage status" });
  }
};

const getGarageLocations = async (req, res) => {
  try {
    const db = await connectDB();
    const garagesCollection = db.collection("garages");

    const locations = await garagesCollection
      .find({}, { projection: { name: 1, location: 1 } })
      .toArray();

    const parsedLocations = locations.map((garage) => ({
      garageId: garage._id.toString(),
      name: garage.name,
      location: JSON.parse(garage.location),
    }));

    res.status(200).json(parsedLocations);
  } catch (error) {
    console.error("❌ Error fetching garage locations:", error);
    res
      .status(500)
      .json({ message: "An error occurred while fetching locations" });
  }
};

const getGarageInfo = async (req, res) => {
  const userId = req.params.userId;

  try {
    const db = await connectDB();

    const employeesCollection = db.collection("employees");
    const ownersCollection = db.collection("owners");
    const garagesCollection = db.collection("garages");
    const usersCollection = db.collection("users");

    let employee = await employeesCollection.findOne({
      _id: new ObjectId(userId),
    });

    let garageId;

    if (employee) {
      garageId = employee.garage_id;
    } else {
      const owner = await ownersCollection.findOne({
        _id: new ObjectId(userId),
      });
      if (owner) {
        garageId = owner.garage_id;
      } else {
        return res
          .status(404)
          .json({ message: "User not found in employees or owners" });
      }
    }

    const garage = await garagesCollection.findOne({
      _id: new ObjectId(garageId),
    });

    if (!garage) {
      return res.status(404).json({ message: "Garage not found" });
    }

    // Get owner info from users table using owner_id from garage
    const ownerUser = await usersCollection.findOne({
      _id: garage.owner_id,
    });

    if (!ownerUser) {
      return res.status(404).json({ message: "Owner user not found" });
    }

    // Prepare the data to return
    const responseData = {
      name: garage.name,
      location: garage.location,
      ownerInfo: {
        name: ownerUser.name,
        email: ownerUser.email,
        phoneNumber: ownerUser.phoneNumber,
      },
    };

    console.log("Garage Info Response:", responseData); // ✅ This is safe

    // Send the response
    res.status(200).json(responseData);
  } catch (error) {
    console.error("Error in getGarageInfo:", error);
    res.status(500).json({ message: "Failed to fetch garage data" });
  }
};
const getUserGarageData = async (req, res) => {
  try {
    const { userId } = req.params;
    const db = await connectDB();

    // نحول الـ userId إلى ObjectId
    const owner = await db
      .collection("owners")
      .findOne({ _id: new ObjectId(userId) });

    if (!owner) {
      return res.status(404).json({ message: "Owner not found" });
    }

    // نبحث عن الكراج اللي إلو علاقة بالـ owner
    const garage = await db
      .collection("garages")
      .findOne({ owner_id: owner._id });

    if (!garage) {
      return res
        .status(404)
        .json({ message: "Garage not found for this owner" });
    }

    // تحويل الـ garage_id من ObjectId إلى string
    const garageIdStr = garage._id.toString();

    res.status(200).json({ garage_id: garageIdStr });
  } catch (error) {
    console.error("❌ Error fetching garage data:", error);
    res
      .status(500)
      .json({ message: "An error occurred while fetching garage data" });
  }
};

module.exports = {
  addGarage,
  getGarages,
  getGarageById,
  deleteGarage,
  updateGarage,
  updateGarageStatus,
  getGarageLocations,
  getGarageInfo,
  getUserGarageData,
};
