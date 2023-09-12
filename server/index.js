const { CloudTasksClient } = require('@google-cloud/tasks');

// GCloud
const PROJECT_ID = "slowdown-375014"
const LOCATION = 'us-central1';
const QUEUE_NAME = 'slowdown-unpause-queue';


// OneSignal
const ACTIVITY_ID = "slowdown_status";
const APP_ID = "b1bee63a-1006-42bd-bd66-5a803c64f63c";
const REST_API_KEY = "ZjQ5NmY0MDctZDljNi00ODljLWJjODItMWEzMGI1NWNiZTRl";


const client = new CloudTasksClient();

async function createHttpTask() {
    const inSeconds = 180;

    const payload = JSON.stringify({
                event: 'update',
                event_updates: {
                    isConnected: true
                },
                name: 'Internal OneSignal Notification Name',
                contents: { en: 'English Message' },
                headings: { en: 'English Message' },
                sound: 'beep.wav',
                stale_date: Date.now() + 1000 * 60 * 60 * 8,
                dismissal_date: Date.now() + 1000 * 60 * 60 * 24 * 7,
                priority: 10
            });

    const url = `https://onesignal.com/api/v1/apps/${APP_ID}/live_activities/${ACTIVITY_ID}/notifications`;

    // Construct the fully qualified queue name.
    const parent = client.queuePath(PROJECT_ID, LOCATION, QUEUE_NAME);

    const task = {
        httpRequest: {
            headers: {
                accept: 'application/json',
                'Content-Type': 'application/json',
                Authorization: `Basic ${REST_API_KEY}}`
            },
            httpMethod: 'POST',
            url,
        },
    };

    if (payload) {
        task.httpRequest.body = Buffer.from(payload).toString('base64');
    }

    if (inSeconds) {
        // The time when the task is scheduled to be attempted.
        task.scheduleTime = {
            seconds: parseInt(inSeconds) + Date.now() / 1000,
        };
    }

    // Send create task request.
    console.log('Sending task:');
    console.log(task);
    const request = { parent: parent, task: task };
    const [response] = await client.createTask(request);
    console.log(`Created task ${response.name}`);
}

createHttpTask();