import mongoose from "mongoose"

const deviceSchema = new mongoose.Schema({
    deviceId: {
        type: Number,
        required: true,
        unique: true,
    },
    serialNumber: {
        type: String,
        required: true,
        unique: true,
    },
    deviceName: {
        type: String,
    },
    deviceOn: {
        type: Boolean,
        required: true,
        default: false,
    },
    tankHigh: {
        type: Boolean,
        required: true,
        default: false,
    },
    tankLow: {
        type: Boolean,
        required: true,
        default: false,
    },
    tankHigh: {
        type: Boolean,
        required: true,
        default: false,
    },
    storageHigh: {
        type: Boolean,
        required: true,
        default: false,
    },
    storageLow: {
        type: Boolean,
        required: true,
        default: false,
    }
   
})

const Device = mongoose.model('Device', deviceSchema);

export default Device