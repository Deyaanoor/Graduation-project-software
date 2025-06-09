const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");

const addClient = async (req, res) => {
  const { name, email, phoneNumber } = req.body;
  const { owner_id } = req.query;

  try {
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: "Invalid owner_id format" });
    }

    const db = await connectDB();
    const garagesCollection = db.collection("garages");
    const clientsCollection = db.collection("clients");

    const garage = await garagesCollection.findOne({
      owner_id: new ObjectId(owner_id),
    });
    if (!garage) {
      return res
        .status(404)
        .json({ message: "Garage not found for this owner" });
    }

    const existingClient = await clientsCollection.findOne({ email });

    if (existingClient) {
      const garageExists = existingClient.garages?.some(
        (g) => g.garage_id.toString() === garage._id.toString()
      );

      if (garageExists) {
        return res
          .status(400)
          .json({ message: "Client already exists in this garage" });
      }

      await clientsCollection.updateOne(
        { email },
        {
          $push: {
            garages: {
              garage_id: garage._id,
              garage_name: garage.name,
              added_by: new ObjectId(owner_id),
            },
          },
        }
      );

      return res
        .status(200)
        .json({ message: "Garage added to existing client" });
    }

    const newClient = {
      name,
      email,
      phoneNumber,
      garages: [
        {
          garage_id: garage._id,
          garage_name: garage.name,
          added_by: new ObjectId(owner_id),
        },
      ],
    };

    await clientsCollection.insertOne(newClient);
    res.status(201).json({ message: "Client created and added to garage" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error adding client to garage" });
  }
};

const getAllClients = async (req, res) => {
  const { owner_id } = req.query;

  try {
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: "Invalid owner_id format" });
    }

    const db = await connectDB();
    const garagesCollection = db.collection("garages");
    const clientsCollection = db.collection("clients");

    const garages = await garagesCollection
      .find({ owner_id: new ObjectId(owner_id) })
      .toArray();

    if (!garages || garages.length === 0) {
      return res
        .status(404)
        .json({ message: "No garages found for this owner" });
    }

    const clients = await clientsCollection
      .find({
        "garages.garage_id": { $in: garages.map((garage) => garage._id) },
      })
      .project({ name: 1, email: 1, phoneNumber: 1, _id: 0 })
      .toArray();

    res.status(200).json(clients);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching clients" });
  }
};
const deleteClient = async (req, res) => {
  const { email } = req.params;
  const { owner_id } = req.query;

  try {
    if (!ObjectId.isValid(owner_id)) {
      return res.status(400).json({ message: "Invalid owner_id format" });
    }

    const db = await connectDB();
    const garagesCollection = db.collection("garages");
    const clientsCollection = db.collection("clients");
    const usersCollection = db.collection("users");

    const garage = await garagesCollection.findOne({
      owner_id: new ObjectId(owner_id),
    });
    if (!garage) {
      return res
        .status(404)
        .json({ message: "Garage not found for this owner" });
    }

    const result = await clientsCollection.updateOne(
      { email },
      { $pull: { garages: { garage_id: garage._id } } }
    );

    if (result.modifiedCount === 0) {
      return res
        .status(404)
        .json({ message: "Client not found in this garage" });
    }

    const updatedClient = await clientsCollection.findOne({ email });
    if (!updatedClient.garages || updatedClient.garages.length === 0) {
      await clientsCollection.deleteOne({ email });
      await usersCollection.deleteOne({ email });
      return res
        .status(200)
        .json({ message: "Last garage removed. Client and user deleted." });
    }

    res
      .status(200)
      .json({ message: "Garage removed from client successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error removing garage from client" });
  }
};
const getClientGarages = async (req, res) => {
  const { client_id } = req.params;

  try {
    if (!ObjectId.isValid(client_id)) {
      return res.status(400).json({ message: "Invalid client_id format" });
    }

    const db = await connectDB();
    const clientsCollection = db.collection("clients");
    const garagesCollection = db.collection("garages");
    const ownersCollection = db.collection("owners");
    const client = await clientsCollection.findOne({
      _id: new ObjectId(client_id),
    });

    if (!client || !client.garages || client.garages.length === 0) {
      return res
        .status(404)
        .json({ message: "No garages found for this client" });
    }

    const garageIds = client.garages.map((g) => g.garage_id);

    const garages = await garagesCollection
      .find({ _id: { $in: garageIds } })
      .toArray();
    const owner = await ownersCollection.findOne({
      _id: garages[0].owner_id,
    });

    res.status(200).json(
      garages.map((garage) => ({
        garageId: garage._id,
        name: garage.name,
        location: garage.location,
        ownerName: owner.name,
        ownerEmail: owner.email,
      }))
    );
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error fetching garages" });
  }
};

module.exports = {
  addClient,
  getAllClients,
  deleteClient,
  getClientGarages,
};
