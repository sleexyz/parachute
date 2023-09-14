import { CloudTasksClient } from '@google-cloud/tasks';
import * as functions from '@google-cloud/functions-framework';

// GCloud
const PROJECT_ID: string = "slowdown-375014"
const LOCATION: string = 'us-central1';
const QUEUE_NAME: string = 'slowdown-unpause-queue';


// OneSignal
const APP_ID: string = "b1bee63a-1006-42bd-bd66-5a803c64f63c";
const REST_API_KEY: string = "ZjQ5NmY0MDctZDljNi00ODljLWJjODItMWEzMGI1NWNiZTRl";


functions.http('register_activity_refresh', async (req: any, res: any) => {
    const activityId: string = req.body.activityId;
    // Date in milliseconds
    const refreshDate: number = req.body.refreshDate;

    try {
        await ActivityRefreshService.shared.cancelActivityRefreshTask({ activityId });
    } catch (e) {
        console.log(e);
    }

    const taskName = await ActivityRefreshService.shared.registerActivityRefreshTask({ activityId, refreshDate });

    res.json({
        taskName
    });
});



functions.http('cancel_activity_refresh', async (req: any, res: any) => {
    const activityId: string = req.body.activityId;

    await ActivityRefreshService.shared.cancelActivityRefreshTask({ activityId });

    res.json({});
});

const client: CloudTasksClient = new CloudTasksClient();

function hashCode(str: string): number {
    var hash: number = 0,
        i: number, chr: number;
    if (str.length === 0) return hash;
    for (i = 0; i < str.length; i++) {
        chr = str.charCodeAt(i);
        hash = ((hash << 5) - hash) + chr;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
}

class ActivityRefreshService {
    private constructor() {}
    static shared = new ActivityRefreshService();

    async registerActivityRefreshTask({ activityId, refreshDate }: { activityId: string, refreshDate: number }): Promise<string | null | undefined> {
        const payload: string = JSON.stringify({
            event: 'update',
            event_updates: {
                isConnected: true
            },
            name: 'Internal OneSignal Notification Name',
            contents: { en: 'English Message' },
            headings: { en: 'English Message' },
            sound: 'beep.wav',
            stale_date: refreshDate + 1000 * 60 * 60 * 8,
            dismissal_date: refreshDate + 1000 * 60 * 60 * 24 * 7,
            priority: 10
        });

        const url: string = `https://onesignal.com/api/v1/apps/${APP_ID}/live_activities/${activityId}/notifications`;

        // Construct the fully qualified queue name.
        const parent: string = client.queuePath(PROJECT_ID, LOCATION, QUEUE_NAME);

        const taskId: string = `${activityId}--${hashCode(refreshDate.toString())}`

        const task = {
            name: client.taskPath(PROJECT_ID, LOCATION, QUEUE_NAME, taskId),
            httpRequest: {
                url,
                headers: {
                    accept: 'application/json',
                    'Content-Type': 'application/json',
                    Authorization: `Basic ${REST_API_KEY}}`
                },
                httpMethod: 'POST' as 'POST',
                body: Buffer.from(payload).toString('base64')
            },
            // The time when the task is scheduled to be attempted.
            scheduleTime: {
                seconds: refreshDate / 1000,
            },
        };

        // Send create task request.
        console.log('Sending task:');
        console.log(task);
        const request = { parent: parent, task: task };
        const [response] = await client.createTask(request);
        console.log(`Created task ${response.name}`);
        return response.name;
    }

    async cancelActivityRefreshTask({ activityId }: { activityId: string }): Promise<void> {
        const resp = await client.listTasks({
            parent: client.queuePath(PROJECT_ID, LOCATION, QUEUE_NAME),
        });
        for (const task of resp[0]) {
            let taskId: string = task.name?.split('/').pop() || '';
            if (taskId.includes(activityId)) {
                await client.deleteTask({ name: task.name });
                console.log(`Deleted task ${task.name}`);
            }
        }
    }
}