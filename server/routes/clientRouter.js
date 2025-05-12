const express = require('express');
const {addClient,deleteClient,getAllClients,getClientGarages} = require('../controllers/clientController');
const router = express.Router();

router.get('/', getAllClients);  

router.post('/add-client', addClient); 

router.delete('/client/:email', deleteClient); 
router.get('/client-garages/:client_id', getClientGarages);




module.exports = router;
