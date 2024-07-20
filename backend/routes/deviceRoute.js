import express from 'express'
import { addDevice, changeDeviceStatus, changeTankStates, removeDevice } from '../controllers/deviceController.js'

const router = express.Router()

router.route("/add-device")
    .post(addDevice)

router.route("/remove-device")
    .delete(removeDevice)

router.route("/change-devicestatus")
    .post(changeDeviceStatus)

router.route("/change-tankstates")
    .post(changeTankStates)
export default router