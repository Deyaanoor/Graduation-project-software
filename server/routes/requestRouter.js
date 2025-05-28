const express = require('express');
const { addRequest, getRequests, getRequestById, updateRequestStatus,getRequestsByUserAndGarageId
    ,addMessageToRequest,
  getRequestMessages,deleteRequest
 } = require('../controllers/requestController');
const router = express.Router();

router.get('/:ownerId', getRequests);

router.post('/add-request', addRequest);
router.post('/requests/:requestId/messages', addMessageToRequest);


router.get('/:id', getRequestById);
router.get('/:userId/:garageId', getRequestsByUserAndGarageId);
router.put('/update-status/:id', updateRequestStatus);
router.get('/requests/:requestId/messages', getRequestMessages);
router.delete('/requests/:requestId', deleteRequest);





module.exports = router;
