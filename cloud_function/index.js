const admin = require("firebase-admin");
admin.initializeApp();
const messaging = require("firebase-admin/messaging")
const firestore = require("firebase-admin/firestore")
const db = firestore.getFirestore();
const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onMessagePublished } = require("firebase-functions/v2/pubsub");

exports.send_fcm_notification = onMessagePublished(
    {
        topic: "notification_scheduler",
        region: "asia-south1",
    },
    async (event) => {
        console.log("onMessagePublished");

        const now = new Date();
        const hour = now.getHours().toString();
        const minute = now.getMinutes() < 10
            ? `${Math.floor(now.getMinutes() / 5)}`
            : now.getMinutes() % 10 < 5
                ? `${Math.floor(now.getMinutes() / 10)}0`
                : `${Math.floor(now.getMinutes() / 10)}5`;
        const timeSlot = `${hour}:${minute}`;

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
            const messages = [];
            snapshot.forEach((doc) => {
                const habit = doc.data();
                console.log(`habit: ${JSON.stringify(habit)}`);
                const topic = habit.userId;
                const message = {
                    data: { data: JSON.stringify(habit) },
                    topic: topic
                };
                console.log(`Message queued for topic: ${topic} , message: ${JSON.stringify(message)}`);
                messages.push(message);
            });

            if (messages) {
                return messaging.getMessaging().sendEach(messages)
                    .then((response) => {
                        console.log(`✅ Messages sent to ${messages.length} users. Success: ${response["successCount"]}, Failure: ${response["failureCount"]}`);
                        console.log(`Response: ${JSON.stringify(response)}`);
                    })
                    .catch((error) => {
                        console.error(`❌ Error sending messages":`, error);
                    });
            } else {
                console.log(`No messages to schedule`);
            }

        } catch (error) {
            console.error("❌ Error fetching scheduled habits:", error);
            return null;
        }
    }
);

// gcloud functions deploy send_fcm_notification  --runtime nodejs20  --trigger-topic notification_scheduler  --entry-point send_fcm_notification  --region=asia-south1


// 🧹 New function: delete `histories` subcollection when habit is deleted
exports.deleteHabitHistory = onDocumentDeleted(
    {
        document: "{userId}/data/habits/{habitId}",
        region: "asia-south1"
    }, async (event) => {
        console.log("Habit deleted: " + event.document);
        const { userId, habitId } = event.params;
        const historiesPath = `${userId}/data/habits/${habitId}/history`;
        const historiesRef = db.collection(historiesPath);
        return await db.recursiveDelete(historiesRef).then(
            (value) => {
                console.log("Histories deleted at path " + historiesPath);
            },
            (error) => {
                console.log("Error occurred while deleting histories at path " + historiesPath);
                console.log(JSON.stringify(error));
            });
    });