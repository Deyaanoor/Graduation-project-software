const express = require('express');
const { addRequest, getRequests, getRequestById, updateRequestStatus,getRequestsByUserAndGarageId } = require('../controllers/requestController');
const router = express.Router();

router.get('/:ownerId', getRequests);

router.post('/add-request', addRequest);

router.get('/:id', getRequestById);

router.get('/:userId/:garageId', getRequestsByUserAndGarageId);

router.put('/update-status/:id', updateRequestStatus);

module.exports = router;
