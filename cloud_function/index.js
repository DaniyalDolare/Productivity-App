// import { getFirestore } from "firebase-admin/firestore";
// import { initializeApp } from "firebase-admin/app";
// initializeApp();
// let db = getFirestore();

const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.send_fcm_notification = async (message, context) => {
    console.log("onMessagePublished2");

    const now = new Date();
    const hour = now.getHours().toString();
    const minute = now.getMinutes() < 10
        ? `${Math.floor(now.getMinutes() / 5)}`
        : now.getMinutes() % 10 < 5
            ? `${Math.floor(now.getMinutes() / 10)}0`
            : `${Math.floor(now.getMinutes() / 10)}5`;
    const timeSlot = `${hour}:${minute}`;

    // let currentTimeSlot = `${now.getHours()}:${now.getMinutes()}`; // "HH:mm" in UTC
    // console.log(`currentTimeSlot: ${currentTimeSlot}`);
    // currentTimeSlot = '16:30';

    try {
        const scheduledHabitsRef = db
            .collection("scheduledHabits")
            .doc(timeSlot)
            .collection("scheduledHabits");
        const snapshot = await scheduledHabitsRef.get();

        if (snapshot.empty) {
            console.log(`ℹ️ No scheduled habits found for time slot: ${timeSlot}`);
            return null;
        }

        // const messages = [];
        const messagePromises = [];

        snapshot.forEach((doc) => {
            const habit = doc.data();
            console.log(`habit: ${JSON.stringify(habit)}`);

            const topic = habit.userId;
            // const topic = "topic";

            const message = {
                // notification: {
                //     title: "Habit Reminder",
                //     body: habit.title || "Time to check your habit!"
                // },
                data: { data: JSON.stringify(habit) },
                // android: {
                //     ttl: 86400000,
                //     priority: "high",
                //     notification: {
                //         channel_id: "com.daniyal.productivity_app/habit",
                //         sticky: true,
                //         priority: "max"
                //     }
                // },
                topic: topic
            };
            console.log(`Message queued for topic: ${topic} , message: ${JSON.stringify(message)}`);
            // messages.push(message);

            const promise = admin.messaging().send(message).then((response) => {
                console.log(`✅ Messages sent to respected users. Response: ${JSON.stringify(response)}`);
            })
                .catch((error) => {
                    console.error(`❌ Error sending messages":`, error);
                });
            messagePromises.push(promise);
        });

        // if (messages) {
        //     await admin.messaging().sendEach(messages)
        //         .then((response) => {
        //             console.log(`✅ Messages sent to respected users. Response: ${JSON.stringify(response)}`);
        //         })
        //         .catch((error) => {
        //             console.error(`❌ Error sending messages":`, error);
        //         });
        // } else {
        //     console.log(`No messages to schedule`);
        // }

        Promise.all(messagePromises);

    } catch (error) {
        console.error("❌ Error fetching scheduled habits:", error);
        return null;
    }
};

// gcloud functions deploy send_fcm_notification  --runtime nodejs20  --trigger-topic notification_scheduler  --entry-point send_fcm_notification  --region=asia-south1
